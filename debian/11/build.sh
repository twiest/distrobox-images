#!/bin/bash

RED='\033[0;31m'
NO_COLOR='\033[0m'


err_report() {
    echo
    echo
    echo -e "${RED}Error $1 occured on line $2${NO_COLOR}"
    echo
    exit $1
}

trap 'err_report $? $LINENO' ERR

set -eou pipefail

cd $(dirname $(readlink -f $0))

img_name=distrobox-$(basename $(dirname $PWD))
img_ver=$(basename $PWD)
date_stamp=$(date +%Y-%m-%d)

time podman build $@ . -t "${img_name}:${date_stamp}" -t "${img_name}:${img_ver}"
