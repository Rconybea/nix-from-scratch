#!/bin/bash
#
# Require:
# 1. nxfs_sysroot      [$HOME/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot]
#
# Use
#   $ cd nxfspkgs/bootstrap/nxfs-sysroot-0
#   $ ./coppy2nix.sh

set -euo pipefail

declare nxfs_toolchain_prefix
nxfs_toolchain_prefix=${NXFS_TOOLCHAIN_PREFIX:-${HOME}/nxfs-toolchain}

# must match the directory name we're picking up.
# (unless want to copy it first)
# path ${nxfs_toolchain_prefix}/${sysroot_name}/
declare sysroot_name
sysroot_name=x86_64-pc-linux-gnu

declare nxfs_sysroot
nxfs_sysroot=${nxfs_toolchain_prefix}/${sysroot_name}

# establish output hash for target dir tree
#
target_sha256=$(nix-hash --type sha256 --base32 ${nxfs_sysroot})

# add target dir tree to nix store
#
# works w/ nix 2.24:
nix store add --hash-algo sha256 ${nxfs_sysroot}
# works w/ nix 2.16
#nix-store --add ${nxfs_sysroot}

# create fixed-output derivation (FOD) using the obtained hash
#
cat <<EOF > default.nix
# automatically created by nxfspkgs/bootstrap/copy2nix.sh -- DO NOT EDIT

derivation {
  name = "${sysroot_name}";
  system = "x86_64-linux";
  builder = ./builder.sh;
  buildInputs = [];
  outputHashAlgo = "sha256";
  outputHash = "${target_sha256}";
  outputHashMode = "recursive";
}

EOF
