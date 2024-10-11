#!/usr/bin/env bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --srcdir=SRCDIR"
}

prefix=
src_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        --srcdir=*)
            src_dir=${1#*=}
            ;;
        *)
            2>&1 echo "${self_name}: unexpected argument ${1}"
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${prefix} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX"
    exit 1
fi

if [[ -z ${src_dir} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty SRCDIR"
    exit 1
fi

set -e
set -x

# if boost supports separate build dir,  it works differently than autotools configure

pushd ../${src_dir}

./bootstrap.sh --prefix=${prefix} --with-python=python3

popd

# scaffold Makefile to compile+install the way boost wants it done

cp ../builddir.mk Makefile

sed -i -e "s:@PREFIX@:${prefix}:" -e "s:@SRCDIR@:${src_dir}:" Makefile
