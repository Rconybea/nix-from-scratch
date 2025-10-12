#!/bin/bash

set -euo pipefail

PREFIX=${HOME}/ext
NIX_PREFIX=$(realpath ${HOME}/nixroot)
NXFS_TOOLCHAIN_PREFIX=${HOME}/nxfs-toolchain
NXFS_HOST_TUPLE=x86_64-pc-linux-gnu
NXFS_BUILD_TUPLE=x86_64-pc-linux-gnu
NXFS_MAX_JOBS=$(nproc)

# adopt config vars into makefiles for nixcpp + nixcpp deps
sed -e s:@prefix@:${PREFIX}: \
    -e s:@nix-prefix@:${NIX_PREFIX}: \
    -e s:@nxfs-toolchain-prefix@:${NXFS_TOOLCHAIN_PREFIX}: \
    -e s:@nxfs-host-tuple@:${NXFS_HOST_TUPLE}: \
    -e s:@nxfs-build-tuple@:${NXFS_BUILD_TUPLE}: \
    -e s:@nxfs-max-jobs@:${NXFS_MAX_JOBS}: \
    ./mk/prefix.in > ./mk/prefix.mk

# make necessary config vars available to nix bootstrap sequence
# (PREFIX not needed -> omitted deliberately)
#
cat <<EOF > nxfspkgs/bootstrap/nxfs-vars.sh
NIX_PREFIX=${NIX_PREFIX}
NXFS_TOOLCHAIN_PREFIX=${NXFS_TOOLCHAIN_PREFIX}
NXFS_HOST_TUPLE=${NXFS_HOST_TUPLE}
NXFS_MAX_JOBS=${NXFS_MAX_JOBS}
EOF
