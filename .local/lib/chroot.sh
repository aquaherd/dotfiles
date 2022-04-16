chroot_mount() 
{
  echo "chroot_mount $1 to $2"
  sudo mkdir -p /run/mount/$2
  sudo mount -t auto $1 /run/mount/$2
  local d
  for d in boot/efi dev dev/pts proc run sys tmp etc/resolv.conf; do
    if [ -e /run/mount/$2/$d ]; then
      sudo mount -o bind /$d /run/mount/$2/$d || echo mount failure in $d
      continue
    fi
    if [ -h /run/mount/$2/$d ]; then
      local l
      l=$(readlink /run/mount/$2/$d)
      sudo mkdir -vp /run/mount/$2/$(dirname $l) || echo mkdir failure $l
      sudo touch /run/mount/$2$l || echo touch failure $l
      sudo mount -o bind /$d /run/mount/$2/$l || echo mount failure in $d -> $l
      continue
    fi
    echo not mounting $d
  done

  for d in Applications Documents Downloads Firmware Logfiles Music Pictures Projects Videos; do
    sudo mount -o bind /mnt/data/hakan/$d /run/mount/$2/home/herd/$d || echo $d was not mounted.
  done
}

chroot_umount() 
{
  echo "chroot_umount $1 from $2"
  #sudo fstrim -v /run/mount/$2
  sudo umount --recursive --lazy /run/mount/$2 && sudo rmdir /run/mount/$2
}
