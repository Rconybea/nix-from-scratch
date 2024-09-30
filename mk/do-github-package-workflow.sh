#!/bin/bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --package=PACKAGE"
}

prefix=
package=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix="${1#*=}"
            ;;
        --package=*)
            package="${1#*=}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

echo "::group::unpack"
make -C pkgs/${package} unpack
echo "::endgroup"

echo "::group::patch"
make -C pkgs/${package} patch
echo "::endgroup"

echo "::group::config"
make -C pkgs/${package} config
echo "::endgroup"

echo "::group::compile"
make -C pkgs/${package} compile
echo "::endgroup"

echo "::group::install"
make -C pkgs/${package} install
echo "::endgroup"

echo "::group::install-tree"
tree ${prefix}
echo "::endgroup"

echo "::group::check runpaths for executables"
./mk/check-runpaths.sh --prefix='${prefix}'
echo "::endgroup"
