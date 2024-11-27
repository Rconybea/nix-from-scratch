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

#nixroot=${HOME}/nixroot
#nxfs_toolchain=${HOME}/nxfs-toolchain
#nxfs_sysroot=${nxfs_toolchain}/x86_64-pc-linux-gnu/sysroot
#nxfs_bootstrap=${nixroot}/bootstrap

#sysroot_dep=$(nix-build ../nxfs-sysroot-0)

# sysroot is a runtime dependency. Mention it in a file so nix knows that.
# (note: current form doesn't seem to be sufficient.
#        nix pills says "relative out-path".  suspect this means we need it
#        also to be a dependency
#
#mkdir -p ${uploaddir}/nix-support
#echo "${sysroot_dep}" > ${uploaddir}/nix-support/nix-dependencies

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
# automatically created by nxfspkgs/bootstrap/nxfs-bash-0/copy2nix.sh -- DO NOT EDIT

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
