#!/bin/bash
#
# Require:
# 1. nxfs_sysroot      [$HOME/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot]
#
# Use
#   $ cd nxfspkgs/bootstrap/nxfs-sysroot-0
#   $

set -e

name=make
uploaddir=./${name}

nixroot=${HOME}/nixroot
#nxfs_toolchain=${HOME}/nxfs-toolchain
#nxfs_sysroot=${nxfs_toolchain}/x86_64-pc-linux-gnu/sysroot
nxfs_bootstrap=${nixroot}/bootstrap

# establish output hash for target dir tree
#
target_sha256=$(nix-hash --type sha256 --base32 ${uploaddir})

# add target dir tree to nix store
#
nix store add --hash-algo sha256 ${uploaddir}

# create fixed-output derivation (FOD) using the obtained hash
#
cat <<EOF > default.nix
# automatically created by nxfspkgs/bootstrap/nxfs-gnumake-0/copy2nix.sh -- DO NOT EDIT

derivation {
  name = "${name}";
  system = "x86_64-linux";
  builder = ./builder.sh;
  buildInputs = [ ];
  outputHashAlgo = "sha256";
  outputHash = "${target_sha256}";
  outputHashMode = "recursive";
}

EOF
