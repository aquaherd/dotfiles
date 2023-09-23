chroot_mount() 
{
  sudo=""
  for s in doas sudo; do
    if command -v $s > /dev/null; then
      sudo=$s 
      break
    fi
  done
  echo "chroot_mount $1 to $2"
  $sudo mkdir -p /run/mount/"$2"
  $sudo mount -t auto "$1" /run/mount/"$2" || return 1
  if ! $sudo chroot /run/mount/"$2" true; then
    echo "$2 was not chrootable"
    return 1
  fi
  local d
  if [ -L /run/mount/"$2"/etc/resolv.conf ]; then
    echo "Moving symlinked resolv.conf away"
    $sudo mv /run/mount/"$2"/etc/resolv.conf /run/"$2"-resolv.conf
    $sudo touch /run/mount/"$2"/etc/resolv.conf
  fi
  for d in mnt/data boot/efi dev dev/pts proc run sys tmp etc/resolv.conf tmp/.X11-unix; do
    if [ -e /run/mount/"$2"/$d ]; then
      $sudo mount -o bind /$d /run/mount/"$2"/$d || echo mount failure in $d
      continue
    fi
    if [ -h /run/mount/"$2"/$d ]; then
      local l
      l=$(readlink /run/mount/"$2"/$d)
      d=$(dirname "$1") 
      $sudo mkdir -vp "/run/mount/$2/$d" || echo mkdir failure "$l"
      $sudo touch "/run/mount/$2$l" || echo touch failure "$l"
      $sudo mount -o bind "/$d" "/run/mount/$2/$l" || echo "mount failure in $d -> $l"
      continue
    fi
    echo "not mounting $d"
  done

  for d in Documents Downloads Firmware Logfiles Music Pictures Projects Videos; do
    $sudo mount -o bind /mnt/data/hakan/$d "/run/mount/$2/home/herd/$d" || echo "$d was not mounted."
  done
}

chroot_umount() 
{
  echo "chroot_umount $1 from $2"
  #$sudo fstrim -v /run/mount/$2
  if [ -L /run/"$2"-resolv.conf ]; then
    echo "Restoring symlinked resolv.conf"
    $sudo mv /run/"$2"-resolv.conf /run/mount/"$2"/etc/
  fi
  $sudo umount --recursive --lazy "/run/mount/$2" && $sudo rmdir "/run/mount/$2"
}
