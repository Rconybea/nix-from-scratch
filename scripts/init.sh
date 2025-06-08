#!/bin/bash
#
# creates top/archive + local {state, log} dirs
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --archive-dir=ARCHIVE_DIR"
}

ARCHIVE_DIR=

while [[ $# > 0 ]]; do
    case "$1" in
        --archive-dir=*)
            ARCHIVE_DIR=${1#*=}
            ;;
        *)
            >&2 echo -n "usage: "
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${ARCHIVE_DIR} ]]; then
    2>&1 echo "$self_name: expected ARCHIVE_DIR (use --archive-dir=ARCHIVE_DIR)"
fi

if [[ ! -d ${ARCHIVE_DIR} ]]; then
    2>&1 echo "$self_name: expected directory: [${ARCHIVE_DIR}]"
fi

set -x
mkdir -p ${ARCHIVE_DIR}
mkdir -p state
mkdir -p log
set +x

# end init.sh
