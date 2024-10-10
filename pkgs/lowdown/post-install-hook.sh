#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX"
}

build_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --builddir=*)
            build_dir=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${build_dir} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty BUILDDIR"
    exit 1
fi

(cd ${build_dir} && make install_static)
(cd ${build_dir} && make install_shared)

