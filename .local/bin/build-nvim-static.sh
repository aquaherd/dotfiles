#!/usr/bin/env bash
# build-static.sh — Build a statically-linked Neovim against musl libc.
#
# Usage: ./build-static.sh [TAG_OR_COMMIT]
#
# Without arguments, builds the current checkout in-place.
# With a tag/commit, creates a temporary git worktree so the current
# checkout is not modified.
#
# Output: static-builds/<label>/nvim  (relative to this script)
#
# Requirements: Debian/Ubuntu with musl-tools and musl-dev installed.
# Will attempt `sudo apt-get install` if musl-gcc is not found.

set -euo pipefail

REPO_DIR=$(pwd)
TAG=${1:-}
OUTPUT_DIR="${REPO_DIR}/static-builds"

# Toolchain file lives in /tmp for the duration of this script.
TOOLCHAIN="/tmp/nvim-musl-toolchain-$$.cmake"
WORK_DIR=""

cleanup() {
    rm -f "$TOOLCHAIN"
    if [[ -n "$WORK_DIR" && "$WORK_DIR" != "$REPO_DIR" ]]; then
        git -C "$REPO_DIR" worktree remove --force "$WORK_DIR" 2>/dev/null || true
        rm -rf "$WORK_DIR"
    fi
}
trap cleanup EXIT

# --- Ensure musl is available ---
if ! command -v musl-gcc &>/dev/null; then
    echo "==> Installing musl-tools musl-dev..."
    sudo apt-get install -y musl-tools musl-dev
fi

# --- Set up working directory ---
if [[ -n "$TAG" ]]; then
    WORK_DIR=$(mktemp -d /tmp/nvim-build-XXXXXX)
    git -C "$REPO_DIR" worktree add "$WORK_DIR" "$TAG"
    LABEL="$TAG"
else
    WORK_DIR="$REPO_DIR"
    LABEL=$(git -C "$REPO_DIR" describe --tags --always --dirty 2>/dev/null \
            || git -C "$REPO_DIR" rev-parse --short HEAD)
fi

echo "==> Building: $LABEL"

# --- Write toolchain file ---
cat > "$TOOLCHAIN" <<'EOF'
set(CMAKE_C_COMPILER musl-gcc)
# musl-gcc uses -nostdinc; add Linux kernel headers at low priority.
string(APPEND CMAKE_C_FLAGS " -idirafter /usr/include/x86_64-linux-gnu -idirafter /usr/include")
EOF

# --- Patch LuaJIT: disable external DWARF unwinding ---
# LuaJIT auto-enables LUAJIT_UNWIND_EXTERNAL on Linux x86-64, which links
# libgcc_eh.a. That archive references _dl_find_object (glibc-only symbol).
# LUAJIT_NO_UNWIND switches to internal setjmp-based unwinding instead.
LUAJIT_CMAKE="${WORK_DIR}/cmake.deps/cmake/BuildLuajit.cmake"
if ! grep -q 'XCFLAGS=-DLUAJIT_NO_UNWIND' "$LUAJIT_CMAKE"; then
    sed -i '/CFLAGS+=-funwind-tables/a\                              XCFLAGS=-DLUAJIT_NO_UNWIND' \
        "$LUAJIT_CMAKE"
fi

# --- Build bundled deps ---
echo "==> Building bundled deps..."
rm -rf "${WORK_DIR}/.deps"
cmake -S "${WORK_DIR}/cmake.deps" -B "${WORK_DIR}/.deps" -G Ninja \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_TOOLCHAIN_FILE="$TOOLCHAIN"
cmake --build "${WORK_DIR}/.deps"

# --- Build Neovim ---
echo "==> Building Neovim (STATIC_BUILD=1)..."
rm -rf "${WORK_DIR}/build"
cmake -S "${WORK_DIR}" -B "${WORK_DIR}/build" -G Ninja \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
    -D STATIC_BUILD=1
cmake --build "${WORK_DIR}/build"

# --- Save and strip output ---
mkdir -p "${OUTPUT_DIR}/${LABEL}"
cp "${WORK_DIR}/build/bin/nvim" "${OUTPUT_DIR}/${LABEL}/nvim"
strip "${OUTPUT_DIR}/${LABEL}/nvim"

# --- Verify ---
echo ""
echo "=== Result ==="
file "${OUTPUT_DIR}/${LABEL}/nvim"
ldd "${OUTPUT_DIR}/${LABEL}/nvim" 2>&1 || true
"${OUTPUT_DIR}/${LABEL}/nvim" --version | head -1
echo ""
echo "==> Saved to: ${OUTPUT_DIR}/${LABEL}/nvim"
