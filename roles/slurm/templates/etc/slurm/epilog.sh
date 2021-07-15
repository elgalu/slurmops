#!/usr/bin/env bash
set -e

echo "INFO: Started $0"

logger -s -t slurm-epilog "START user=${SLURM_JOB_USER} job=${SLURM_JOB_ID}"

# shellcheck disable=SC1009-SC1084
{{ slurm_config_dir }}/shared/bin/run-parts.sh {{ slurm_config_dir }}/epilog.d

logger -s -t slurm-epilog "END user=${SLURM_JOB_USER} job=${SLURM_JOB_ID}"

echo "INFO: Ended $0"
