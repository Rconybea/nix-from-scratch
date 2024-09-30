#!/bin/bash
#
# install step for autoconf projects

self_name=$(basename ${0})

usage() {
    echo "$self_name: --build-dir=BUILDDIR"
}

tarball_path=
build_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --build-dir=*)
            build_dir="${1#*=}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${build_dir} ]]; then
    2>&1 echo "$self_name: expected BUILDDIR (use --build-dir=BUILDDIR)"
    exit 1
fi

if [[ ! -d ${build_dir} ]]; then
    2>&1 echo "$self_name: BUILDDIR: expected directory [${build_dir}]"
    exit 1
fi

set -e

rm -f state/install.result

(cd ${build_dir} && make V=1 install) 2>&1 | tee log/install.log

cp state/compile.result state/install.result

# end install-autoconf.sh
