#!/bin/bash

set -eou pipefail

if [ $# -ne 1 ]; then
  echo
  echo "  Usage: $(basename $0) <permission_domain_for_box>"
  echo
  echo "Example: $(basename $0) financial"
  echo
  exit 10
fi

cd $(dirname $(readlink -f $0))

zone=$1
img_name=distrobox-$(basename $(dirname $PWD))
img_ver=$(basename $PWD)
date_stamp=$(date +%Y-%m-%d)


distrobox_dir="$HOME/distrobox"
home_dir="$distrobox_dir/$zone"

img_name=ghcr.io/twiest/distrobox-$(basename $(dirname $PWD))
img_ver=$(basename $PWD)
date_stamp=$(date +%Y-%m-%d)

has_zfs_dir=false
zfs_fs=
if [ -d "${home_dir}/.zfs" ]; then
  has_zfs_dir=true
  zfs_fs="ssd/zones/${zone}-enc"
  echo -n "Disabling .zfs dir for [$zfs_fs]... "
  sudo zfs set snapdir=hidden "$zfs_fs"
  echo "Done."
fi

mkdir -p "$home_dir"
chown -R twiest:twiest "$home_dir"
distrobox create --nvidia --unshare-process --unshare-groups --unshare-devsys --name "$1" --home "$home_dir" --image "${img_name}:${img_ver}"

if [ "$has_zfs_dir" == "true" ]; then
  echo -n "Re-enabling .zfs dir for [$zfs_fs]... "
  sudo zfs set snapdir=visible "$zfs_fs"
  echo "Done."
fi
