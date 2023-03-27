#!/bin/bash

set -eou pipefail

bin=$0
required_public_ip_file=$HOME/.required_public_ip

if [ -f "${required_public_ip_file}" ]; then
  required_public_ip=$(cat "${required_public_ip_file}" | tr -d '\n')
  public_ip=$(curl ifconfig.me 2> /dev/null)
  if [ "${required_public_ip}" != "${public_ip}" ]; then
    # Requirement not met
    xeyes
    exit 10
  fi
fi

exec ${bin}-real $@
