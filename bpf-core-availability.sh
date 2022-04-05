#!/usr/bin/bash
set -eux -o pipefail

KERNEL_RELEASE="$(uname -r)"

grep 'CONFIG_DEBUG_INFO_BTF=' "/boot/config-$KERNEL_RELEASE"
