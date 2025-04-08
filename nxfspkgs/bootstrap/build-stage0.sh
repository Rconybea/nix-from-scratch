#!/bin/bash

set -euo pipefail

pushd nxfs-cacert-0
./copy2nix.sh
nix-build
popd

pushd nxfs-toolchain-0
./copy2nix.sh
nix-build
popd

pushd nxfs-sysroot-0
./copy2nix.sh
nix-build
popd

stage0pkgs="nxfs-patchelf-0 nxfs-gnumake-0 nxfs-coreutils-0 nxfs-bash-0 nxfs-tar-0 nxfs-sed-0 nxfs-grep-0 nxfs-gawk-0 nxfs-libxcrypt-0 nxfs-findutils-0 nxfs-diffutils-0"

for subdir in $stage0pkgs; do
    pushd $subdir
    make -C stage0 install
    ./copy2nix.sh
    nix-build
    popd
done
