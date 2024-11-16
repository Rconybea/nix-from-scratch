#!/usr/bin/env bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --src-dir=$SRCDIR"
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
    esac

    shift
done

if [[ -z ${prefix} ]]; then
    2>&1 echo "${self_name}: expected non-empty PREFIX (use --prefix=PREFIX)"
    exit 1
fi

if [[ -z ${build_dir} ]]; then
    2>&1 echo "${self_name}: expected non-empty BUILDDIR (use --build-dir=BUILDDIR)"
    exit 1
fi

set -e

pushd ${build_dir}

cp -av libbz2.so* ${prefix}/lib
(cd ${prefix}/lib && ln -sv libbz2.so.1.0 libbz2.so)

popd
