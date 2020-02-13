#!/usr/bin/env bash

__ubuntu_upgrade__()
{
    sudo ${BASH} -c '(set -eu && set -o pipefail && apt-get update && apt-get upgrade --assume-yes && apt-get autoremove --assume-yes)'
}

alias ubuntu_upgrade=__ubuntu_upgrade__