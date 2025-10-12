#!/bin/bash
#
# Require:
# 1. nxfs_sysroot      [$HOME/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot]
# 2. sysroot installed to nix store [nxfspkgs/bootstrap/nxfs-sysroot-0]
#
# Use
#   $ cd nxfspkgs/bootstrap/nxfs-bash-0/stage0 && make compile && make install
#   $ cd nxfspkgs/bootstrap/nxfs-bash-0 && ./copy2nix.sh

set -e

name=bash
uploaddir=./${name}

# establish output hash for target dir tree
#
target_sha256=$(nix-hash --type sha256 --base32 ${uploaddir})

# add target dir tree to nix store
#
# works w/ nix 2.24
#nix store add --hash-algo sha256 ${uploaddir}
# works w/ nix 2.16
nix-store --add ${uploaddir}

# create fixed-output derivation (FOD) using the obtained hash
#
cat <<EOF > default.nix
# automatically created by nix-from-scratch/nxfspkgs/bootstrap/nxfs-bash-0/copy2nix.sh -- DO NOT EDIT

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
