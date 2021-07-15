#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
set -e

# set -o pipefail: Don't mask errors from a command piped into another command
set -o pipefail

export quiet=false
export larguments=no

usage() {
cat <<EOF
Usage: $(basename "$0") [-h|--help] [--quiet]
    Start rootless docker daemon.
    Example:
        $(basename "$0")

    To omit rootless docker daemon messages redirect output to dev null or
    specify quiet option:
        $(basename "$0") > /dev/null 2>&1

    --quiet - Omit rootless docker messages. Do not use this option when
        troubleshooting.
        Default: ${quiet}

    -h|--help - Displays this help.

EOF
}


while getopts ":h-" arg; do
    case "${arg}" in
        h )
            usage
            exit 2
            ;;
        - )
            [ "${OPTIND}" -ge 1 ] && optind=$((OPTIND - 1)) || optind="${OPTIND}"
            eval __OPTION="\$$optind"
            OPTARG="$(echo "${__OPTION}" | cut -d'=' -f2)"
            OPTION="$(echo "${__OPTION}" | cut -d'=' -f1)"
            case $OPTION in
            --quiet ) larguments=no; quiet=true  ;;
            --help ) usage; exit 2 ;;
            esac
            OPTIND=1
            shift
            ;;
        *)
            usage
            exit 3
            ;;
    esac
done


function start_docker_rootless() {
    # Expects environment vars XDG_RUNTIME_DIR, DOCKER_HOST, and
    # DOCKER_DATAROOT to be set. Also, rootless docker i.e. docker-rootless.sh
    # needs to be on the PATH.

    # userid="$(id -u)"

    # Using dockerd
    # export XDG_RUNTIME_DIR=/var/tmp/xdg_runtime_dir_${userid}
    [ -z "${XDG_RUNTIME_DIR}" ] && echo "Missing env var XDG_RUNTIME_DIR" && exit 113
    [ -z "${DOCKER_DATAROOT}" ] && echo "Missing env var DOCKER_DATAROOT" && exit 114
    mkdir -p "${XDG_RUNTIME_DIR}"
    # export DOCKER_HOST=unix://${XDG_RUNTIME_DIR}/docker.sock

    # You can fallback to vfs when overlay2 but it's too slow
    dockerd-rootless.sh --experimental \
      --data-root="${DOCKER_DATAROOT}" \
      --storage-driver overlay2 &

    # Insure that docker daemon started.
    docker ps >/dev/null
    # shellcheck disable=SC2181
    while [ $? -ne 0 ]; do
        docker ps >/dev/null
    done

}

if [ "$quiet" = true ] ; then
    start_docker_rootless >/dev/null 2>&1
else
    start_docker_rootless
fi
