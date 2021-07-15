#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
set -e

# set -o pipefail: Don't mask errors from a command piped into another command
set -o pipefail

export EASYBUILD_PREFIX="{{ sm_prefix }}"
export EASYBUILD_MODULES_TOOL=Lmod
module purge
unset "$(env | grep EBROOT | awk -F'=' '{print $1}')"
module load EasyBuild
