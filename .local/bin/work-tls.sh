#!/usr/bin/env bash
#
# work-tls.sh - Idempotently download and install TLS root & intermediate certificate chains
# for Debian system ca-certificates and Firefox.
#
# Usage:
#   work-tls.sh [URL_OR_HOST]
#

set -euo pipefail

DEFAULT_URL="https://hr-services.siemens-healthineers.com/"
TARGET="${1:-$DEFAULT_URL}"

# Extract hostname and port
RAW_HOST="${TARGET#*://}" # strip protocol
RAW_HOST="${RAW_HOST%%/*}" # strip path
RAW_HOST="${RAW_HOST%%:*}" # strip port for hostname
PORT="443"
if [[ "$TARGET" =~ :([0-9]+) ]]; then
    PORT="${BASH_REMATCH[1]}"
fi
HOST="$RAW_HOST"

if [ -z "$HOST" ]; then
    echo "[-] Error: Invalid target host/URL: $TARGET" >&2
    exit 1
fi

echo "[*] Target host: $HOST:$PORT"

TMP_DIR="$(mktemp -d -t work-tls-XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

WORKDIR="$TMP_DIR"

# 1. Fetch presented TLS certificates
echo "[*] Fetching TLS certificates from $HOST:$PORT..."
python3 - "$HOST" "$PORT" "$WORKDIR" << 'EOF'
import sys, subprocess, os, re

host = sys.argv[1]
port = sys.argv[2]
workdir = sys.argv[3]

proc = subprocess.run(
    ["openssl", "s_client", "-showcerts", "-connect", f"{host}:{port}", "-servername", host],
    input=b"",
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL
)

output = proc.stdout.decode("utf-8", errors="replace")
certs = []
curr = []
in_cert = False

for line in output.splitlines():
    if "-----BEGIN CERTIFICATE-----" in line:
        in_cert = True
        curr = [line]
    elif "-----END CERTIFICATE-----" in line:
        curr.append(line)
        in_cert = False
        certs.append("\n".join(curr) + "\n")
    elif in_cert:
        curr.append(line)

print(f"[*] Retrieved {len(certs)} certificate(s) presented by server.")
for i, c in enumerate(certs):
    with open(os.path.join(workdir, f"chain_{i}.pem"), "w") as f:
        f.write(c)
EOF

if [ ! -f "$WORKDIR/chain_0.pem" ]; then
    echo "[-] Failed to retrieve any certificates from $HOST:$PORT" >&2
    exit 1
fi

# Function to extract AIA CA Issuers URLs from a certificate
get_aia_urls() {
    local cert="$1"
    openssl x509 -in "$cert" -noout -text 2>/dev/null \
        | awk -F'URI:' '/CA Issuers - URI:/ {print $2}' \
        | tr -d ' '
}

# Follow AIA chain upwards to find all intermediate and root CAs
echo "[*] Resolving full certificate chain via AIA..."
ALL_CERTS=("$WORKDIR"/chain_*.pem)
PROCESSED_URLS=()

idx=${#ALL_CERTS[@]}
queue=()

for cert in "${ALL_CERTS[@]}"; do
    for url in $(get_aia_urls "$cert"); do
        queue+=("$url")
    done
done

while [ ${#queue[@]} -gt 0 ]; do
    url="${queue[0]}"
    queue=("${queue[@]:1}")

    # Check if URL already processed
    skip=0
    for seen in "${PROCESSED_URLS[@]:-}"; do
        if [ "$seen" = "$url" ]; then
            skip=1
            break
        fi
    done
    [ $skip -eq 1 ] && continue
    PROCESSED_URLS+=("$url")

    # Only fetch HTTP/HTTPS URLs
    if [[ ! "$url" =~ ^https?:// ]]; then
        continue
    fi

    echo "[*] Fetching issuer certificate from: $url"
    out_raw="$WORKDIR/downloaded_${idx}.raw"
    out_pem="$WORKDIR/downloaded_${idx}.pem"

    if curl -sSL --connect-timeout 10 "$url" -o "$out_raw" && [ -s "$out_raw" ]; then
        if openssl x509 -in "$out_raw" -inform DER -out "$out_pem" -outform PEM 2>/dev/null || \
           openssl x509 -in "$out_raw" -inform PEM -out "$out_pem" -outform PEM 2>/dev/null; then
            ALL_CERTS+=("$out_pem")
            # Enqueue further AIA URLs
            for next_url in $(get_aia_urls "$out_pem"); do
                queue+=("$next_url")
            done
            idx=$((idx + 1))
        fi
    fi
done

# Prepare Debian system CA store
TARGET_CA_DIR="/usr/local/share/ca-certificates/work-tls"
sudo mkdir -p "$TARGET_CA_DIR"

SYSTEM_UPDATED=0

# Check if a certificate with identical fingerprint already exists in /usr/local/share/ca-certificates
cert_already_in_system() {
    local cert="$1"
    local fp
    fp=$(openssl x509 -in "$cert" -noout -fingerprint -sha256 2>/dev/null || true)
    [ -z "$fp" ] && return 1

    while IFS= read -r existing_file; do
        [ -f "$existing_file" ] || continue
        local existing_fp
        existing_fp=$(openssl x509 -in "$existing_file" -noout -fingerprint -sha256 2>/dev/null || true)
        if [ "$fp" = "$existing_fp" ]; then
            return 0
        fi
    done < <(find /usr/local/share/ca-certificates -type f -name "*.crt")
    return 1
}

# Install root & intermediate CAs
echo "[*] Processing certificates for Debian trust store and Firefox..."
SEEN_FINGERPRINTS=()

for cert in "${ALL_CERTS[@]}"; do
    subject=$(openssl x509 -in "$cert" -noout -subject -nameopt RFC2253 2>/dev/null || true)
    issuer=$(openssl x509 -in "$cert" -noout -issuer -nameopt RFC2253 2>/dev/null || true)
    cn=$(openssl x509 -in "$cert" -noout -subject 2>/dev/null | sed -n 's/.*CN = \([^/,]*\).*/\1/p' | tr -s ' ' | tr ' /' '_')
    is_ca=$(openssl x509 -in "$cert" -noout -text 2>/dev/null | grep -A 1 "Basic Constraints" | grep "CA:TRUE" || true)

    if [ -z "$is_ca" ]; then
        # Skip leaf / end-entity certificates for CA store
        continue
    fi

    cert_fp=$(openssl x509 -in "$cert" -noout -fingerprint -sha256 2>/dev/null || true)
    # Skip duplicates within this run
    if [[ " ${SEEN_FINGERPRINTS[*]:-} " =~ " ${cert_fp} " ]]; then
        continue
    fi
    SEEN_FINGERPRINTS+=("$cert_fp")

    [ -z "$cn" ] && cn="ca_cert_$(openssl x509 -in "$cert" -noout -serial | cut -d= -f2)"
    dest_crt="$TARGET_CA_DIR/${cn}.crt"

    if ! cert_already_in_system "$cert"; then
        echo "[+] Installing CA certificate: $cn into $TARGET_CA_DIR"
        sudo cp "$cert" "$dest_crt"
        sudo chmod 644 "$dest_crt"
        SYSTEM_UPDATED=1
    else
        echo "[=] CA certificate $cn already present in system store."
    fi

    # Import into Firefox NSS databases
    for prof in ~/.mozilla/firefox/*.default* ~/.mozilla/firefox/*default-esr*; do
        if [ -d "$prof" ] && [ -f "$prof/cert9.db" ]; then
            cert_name="$(openssl x509 -in "$cert" -noout -subject 2>/dev/null | sed -n 's/.*CN = \([^/,]*\).*/\1/p')"
            [ -z "$cert_name" ] && cert_name="$cn"
            
            # Use 'C,,' trust for root CAs (subject == issuer), ',,' for intermediates
            if [ "$subject" = "$issuer" ]; then
                trust="C,,"
            else
                trust=",,"
            fi

            if ! certutil -d sql:"$prof" -L -n "$cert_name" >/dev/null 2>&1; then
                echo "[+] Importing into Firefox profile $(basename "$prof"): $cert_name"
                certutil -d sql:"$prof" -A -t "$trust" -n "$cert_name" -i "$cert"
            fi
        fi
    done
done

# Update Debian system trust if any CA was updated
if [ $SYSTEM_UPDATED -eq 1 ]; then
    echo "[*] Updating system certificate trust store..."
    sudo update-ca-certificates
fi

# Ensure Firefox Enterprise Roots and policies
echo "[*] Ensuring Firefox enterprise policies..."
sudo mkdir -p /etc/firefox-esr/policies /etc/firefox/policies

POLICIES_JSON='{
  "policies": {
    "ImportEnterpriseRoots": true
  }
}'

for ppath in /etc/firefox-esr/policies/policies.json /etc/firefox/policies/policies.json; do
    if [ ! -f "$ppath" ] || ! grep -q "ImportEnterpriseRoots" "$ppath" 2>/dev/null; then
        echo "$POLICIES_JSON" | sudo tee "$ppath" >/dev/null
    fi
done

if [ -f /etc/firefox-esr/firefox-esr.js ]; then
    if ! grep -q "security.enterprise_roots.enabled" /etc/firefox-esr/firefox-esr.js; then
        echo 'pref("security.enterprise_roots.enabled", true);' | sudo tee -a /etc/firefox-esr/firefox-esr.js >/dev/null
    fi
fi

# Verification
echo "[*] Testing HTTPS connection to $TARGET..."
if curl -I -sS "$TARGET" >/dev/null 2>&1; then
    echo "[✓] Success: TLS trust established for $TARGET"
else
    echo "[!] Warning: curl check returned non-zero. Testing with verbose output:"
    curl -I "$TARGET" || true
fi