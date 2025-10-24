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

img_name=ghcr.io/twiest/distrobox-$(basename $(dirname $PWD))
img_ver=$(basename $PWD)

distrobox_name="$1"


# does the distrobox exist?
if ! distrobox list --no-color | awk -F\| '{print $2}' | grep "$distrobox_name" &> /dev/null; then
  echo
  echo "ERROR: distrobox [$distrobox_name] doesn't exist"
  echo
  exit 10
fi

# is the distrobox currently using this image?
if ! distrobox list --no-color | awk -F\| '{print $2 $4}' | grep "${distrobox_name} * ${img_name}:${img_ver}" &> /dev/null; then
  echo
  echo "ERROR: distrobox [$distrobox_name] isn't using image [${img_name}:${img_ver}]"
  echo
  exit 10
fi

echo "Pulling latest image from ghcr [${img_name}:${img_ver}]..."
podman pull "${img_name}:${img_ver}"

echo "Removing existing distrobox instance [$distrobox_name]..."
distrobox rm -f "$distrobox_name"

echo "Waiting 3 seconds otherwise distrobox may fail to create..."
sleep 3

echo -n "Removing Brave Singletons... "
rm "/var/home/twiest/distrobox/${distrobox_name}/.config/BraveSoftware/Brave-Browser/Singleton"* || :
echo "Done."

echo "Creating distrobox instance [$distrobox_name]..."
./create-distrobox.sh "$distrobox_name"
