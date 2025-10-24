#!/bin/bash

set -eou pipefail

bin=$0
required_public_ip_file=$HOME/.required_public_ip

if [ -f "${required_public_ip_file}" ]; then
  required_public_ip=$(cat "${required_public_ip_file}" | tr -d '\n')
  public_ip=$(curl ifconfig.me 2> /dev/null)
  if [ "${required_public_ip}" != "${public_ip}" ]; then
    # Requirement not met
    xeyes # TODO: use a gui text prompt, xeyes is placeholder for now
    exit 10
  fi
fi

if [ -z "$HOSTNAME" ]; then
  echo "HOSTNAME not set"
  exit 11
fi

new_bin="${bin}-${HOSTNAME}"
if ! [ -f "${new_bin}" ]; then
  # Only do this the first time
  sudo mv "${bin}-real" "${new_bin}"
fi

exec "$new_bin" $@
