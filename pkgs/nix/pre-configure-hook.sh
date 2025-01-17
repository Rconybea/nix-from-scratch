#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --srcdir=SRCDIR"
}

src_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --srcdir=*)
            src_dir=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${src_dir} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty SRCDIR"
    exit 1
fi

set -x
set -e

cd ../${src_dir}
echo 2>&1 'pre-configure-hook: libtoolize'
libtoolize
echo 2>&1 'pre-configure-hook: autoreconf -fi'
autoreconf -fi
echo 2>&1 'pre-configure-hook: autoreconf --install'
autoreconf --install
