#!/bin/bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: [--prefix=PREFIX] [--nxfs-toolchain-prefix=NXFS_TOOLCHAIN_PREFIX"
}

prefix=
nxfs_toolchain_prefix=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix="${1#*=}"
            ;;
        --nxfs-otoolchain_prefix=*)
            nxfs_toolchain_prefix="${1#*=}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -n ${prefix} ]]; then
    sed -i -e "s|^PREFIX:=.*$|PREFIX:=${prefix}|" mk/prefix.mk
fi

if [[ -n ${nxfs_toolchain_prefix} ]]; then
    sed -i -e "s|^NXFS_TOOLCHAIN_PREFIX:=.*$|NXFS_TOOLCHAIN_PREFIX:=${nxfs_toolchain_prefix}|" mk/prefix.mk
fi
