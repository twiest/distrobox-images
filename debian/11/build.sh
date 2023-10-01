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

# MUST use "--format docker" because the FROM container images has a HEALTHCHECK. Otherwise I get this warning:
#      WARN[0138] HEALTHCHECK is not supported for OCI image format and will be ignored. Must use `docker` format
time podman build --format docker $@ . -t "${img_name}:${date_stamp}" -t "${img_name}:${img_ver}"
