#!/usr/bin/env xonsh

import sys

max_retries = 100

$XONSH_SHOW_TRACEBACK = True

script_dir = $(realpath $(dirname @($ARGS[0]))).strip()

cd @(script_dir)

distro = $(basename $(dirname $PWD)).strip()
img_name = f"distrobox-{ distro }".strip()
img_ver = $(basename $PWD).strip()

result = None
for i in range(1, max_retries + 1):
    echo
    echo --------------------------------------------------------------------------------
    echo -n f"Attempt { i }/{ max_retries } - "
    date
    echo
    result_1 = ![time -p podman push f"ghcr.io/twiest/{ img_name }:latest"]
    result_2 = ![time -p podman push f"ghcr.io/twiest/{ img_name }:{ img_ver }"]
    if result_1.returncode == 0 and result_2.returncode == 0:
        break

    echo "Sleeping 10 seconds before next retry... "
    sleep 10

# Return with same returncode as the cmd
sys.exit(max(result_1.returncode, result_2.returncode))
