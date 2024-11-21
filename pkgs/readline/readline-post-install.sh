#!/bin/bash
#

# runs in package dir

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX -build-dir=BUILDDIR"
}

prefix=
build_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        --build-dir=*)
            build_dir=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

set -e

if [[ ! -d "${prefix}" ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX directory"
    exit 1
fi

if [[ ! -d "${build_dir}" ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty BUILDDIR directory"
    exit 1
fi

patchelf --add-needed libncursesw.so.6 ${prefix}/lib/libreadline.so

