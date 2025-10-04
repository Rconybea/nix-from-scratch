#!/bin/bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --package=PACKAGE"
}

prefix=
package=
jobs=1

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix="${1#*=}"
            ;;
        --package=*)
            package="${1#*=}"
            ;;
        --max-jobs=*)
            jobs="${1#*=}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z "${prefix}" ]];
then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX (use --prefix=PREFIX)"
    exit 1
fi

if [[ -z "${package}" ]];
then
    2>&1 echo "error: ${self_name}: expected non-empty PACKAGE (use --package=PACKAGE)"
    exit 1
fi

set -e

echo "::group::unpack"
make -C ${package} unpack
echo "::endgroup"

echo "::group::patch"
make -C ${package} patch
echo "::endgroup"

echo "::group::config"
make -C ${package} config NXFS_MAX_JOBS=${jobs}
echo "::endgroup"

echo "::group::compile"
make -C ${package} compile NXFS_MAX_JOBS=${jobs}
echo "::endgroup"

echo "::group::install"
make -C ${package} install
echo "::endgroup"

echo "::group::install-tree (simplified)"
# tree will return non-zero exit code if filelimit triggered
tree -L 3 --filelimit=15 ${prefix} || true
echo "::endgroup"

echo "::group::check runpaths for executables"
./scripts/check-runpaths.sh --prefix=${prefix}
echo "::endgroup"
