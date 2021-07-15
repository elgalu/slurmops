#!/usr/bin/env bash

NVARCH="$(uname -s)_$(uname -m)"
export NVARCH

export NVCOMPILERS="{{ hpcsdk_install_dir }}"

export MANPATH="${MANPATH:+$MANPATH:}{{ hpcsdk_install_dir }}/${NVCOMPILERS}/${NVARCH}/{{ hpcsdk_version_dir }}/compilers/man"

export PATH="${NVCOMPILERS}/${NVARCH}/{{ hpcsdk_version_dir }}/compilers/bin:${PATH}"
