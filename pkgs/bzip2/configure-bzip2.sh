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

# 1. This does compile bzip2, not sure why it's required.
# 2. After this is done, we build again from compile phase.
# 3. Applying "Chesterton's fence" principle here, assuming it's done for a reason
#
make -f Makefile-libbz2_so
make clean

popd
