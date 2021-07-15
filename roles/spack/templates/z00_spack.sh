#!/usr/bin/env bash
# -*- shell-script -*-

# set -e: exit asap if a command exits with a non-zero status
set -e

# set -o pipefail: Don't mask errors from a command piped into another command
set -o pipefail

export SPACK_ROOT="{{ spack_install_dir }}"

# shellcheck disable=SC1091
source "${SPACK_ROOT}/share/spack/setup-env.sh"
