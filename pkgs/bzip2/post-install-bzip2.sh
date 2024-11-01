#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX"
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

pushd ${build_dir}

cp -av libbz2.so.* ${prefix}/lib
ln -sfv libbz2.so.1.0.8 ${prefix}/lib/libbz2.so
cp -v bzip2-shared ${prefix}/bzip2
ln -sfv bzip2 ${prefix}/bin/bzcat
ln -sfv bzip2 ${prefix}/bin/bunzip2

popd
