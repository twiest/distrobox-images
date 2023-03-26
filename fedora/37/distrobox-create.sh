#!/bin/bash

if [ $# -ne 1 ]; then
  echo
  echo "  Usage: $(basename $0) <permission_domain_for_box>"
  echo
  echo "Example: $(basename $0) financial"
  echo
  exit 10
fi

cd $(dirname $(readlink -f $0))

img_name=distrobox-$(basename $(dirname $PWD))
img_ver=$(basename $PWD)
date_stamp=$(date +%Y-%m-%d)


distrobox_dir="$HOME/distrobox"
base_dir="$distrobox_dir/$1"
home_dir="$base_dir/home"
var_dir="$base_dir/var"


mkdir -p "$home_dir"
mkdir -p "$var_dir"

cp /etc/skel/.bashrc "$home_dir"
chown -R twiest.twiest "$home_dir"

img_name=distrobox-$(basename $(dirname $PWD))
img_ver=$(basename $PWD)
date_stamp=$(date +%Y-%m-%d)

distrobox create --name "$1" --home "$home_dir" --image "${img_name}:${img_ver}"
