#!/bin/bash

set -euo pipefail

self_name=$(basename ${0})

usage() {
    cat <<EOF
$self_name: [--prefix=PREFIX]                                \
            [--nix-prefix=NIX_PREFIX]                        \
            [--nxfs-toolchain-prefix=NXFS_TOOLCHAIN_PREFIX]  \
            [--nxfs-max-jobs=NXFS_MAX_JOBS]

PREFIX    install nixcpp dependencies (boost, bison, rustc, ..) to this directory
          [$HOME/ext]

NIX_PREFIX
          install path for nixcpp.  'nix' will be in NIX_PREFIX/bin/nix;
          the nix store will be in NIX_PREFIX/nix/store.

NXFS_TOOLCHAIN_PREFIX
          install standalone {gcc, glibc} toolchain to this directory
          Distinct from PREFIX so it can be easily discarded.
          Desirable because install involves multiple steps, across which
          NXFS_TOOLCHAIN_PREFIX passes through unusable states.
          [$HOME/nxfs-toolchain]

NXFS_MAX_JOBS
          drives max number of parallel jobs within a build
          (-j argument to make). Note that link time optimization is memory
          hungry; packages that prepare many exectables can wake up OOM killer.
          Watch out for this with llvm in particular.
          [`nproc`]

EOF
}

PREFIX=${HOME}/ext
NXFS_TOOLCHAIN_PREFIX=${HOME}/nxfs-toolchain
# NOTE: realpath here is load-bearing for nix
NIX_PREFIX=$(realpath ${HOME}/nixroot)
NXFS_HOST_TUPLE=x86_64-pc-linux-gnu
NXFS_BUILD_TUPLE=x86_64-pc-linux-gnu
NXFS_MAX_JOBS=$(nproc)

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            PREFIX="${1#*=}"
            ;;
        --nix-prefix=*)
            NIX_PREFIX="${1#*=}"
            ;;
        --nxfs-toolchain-prefix=*)
            NXFS_TOOLCHAIN_PREFIX="${1#*=}"
            ;;
        --nxfs-max-jobs=*)
            NXFS_MAX_JOBS="${1#*=}"
            ;;
        *)
            echo "error: ${self_name}: unexpected argument [$1]"
            usage
            exit 1
            ;;
    esac

    shift
done

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
# DO NOT EDIT: created automatically by nix-from-scratch/configure.sh

NIX_PREFIX=${NIX_PREFIX}
NXFS_TOOLCHAIN_PREFIX=${NXFS_TOOLCHAIN_PREFIX}
NXFS_HOST_TUPLE=${NXFS_HOST_TUPLE}
NXFS_MAX_JOBS=${NXFS_MAX_JOBS}
EOF

cat <<EOF > nxfspkgs/bootstrap/nxfs-defs.nix
# DO NOT EDIT: created automatically by nix-from-scratch/configure.sh
{
  system = "x86_64-linux";
  target-tuple = "${NXFS_BUILD_TUPLE}";
}
EOF
