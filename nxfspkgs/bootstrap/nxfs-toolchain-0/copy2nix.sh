#!/bin/bash
#
# Require:
# 1. nxfs_sysroot      [$HOME/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot]
#
# Use
#   $ cd nxfspkgs/bootstrap/nxfs-sysroot-0
#   $ ./coppy2nix.sh

set -e

nxfs_toolchain_name=nxfs-toolchain

nxfs_toolchain=${HOME}/${nxfs_toolchain_name}

# establish output hash for target dir tree
#
target_sha256=$(nix-hash --type sha256 --base32 ${nxfs_toolchain})

# add target dir tree to nix store
#
# works w/ nix 2.24:
nix store add --hash-algo sha256 ${nxfs_toolchain}
# works w/ nix 2.16
#nix-store --add ${nxfs_sysroot}

# create fixed-output derivation (FOD) using the obtained hash
#
cat <<EOF > default.nix
# automatically created by nxfspkgs/bootstrap/nxfs-toolchain-0/copy2nix.sh -- DO NOT EDIT

derivation {
  name = "${nxfs_toolchain_name}";
  system = builtins.currentSystem;
  builder = ./builder.sh;
  buildInputs = [];
  outputHashAlgo = "sha256";
  outputHash = "${target_sha256}";
  outputHashMode = "recursive";
}

EOF
