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

(cd ../${src_dir} && libtoolize && autoreconf --install)
