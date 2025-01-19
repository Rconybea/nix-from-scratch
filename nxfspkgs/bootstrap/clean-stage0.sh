#!/bin/bash

# this will clean local (outside-nix-store) builds.
# 1. preserves tarballs from archive directory
# 2. preserves toolchain+sysroot builds
# 3. does not alter nix store state

set -e
set -x

stage0pkgs="nxfs-patchelf-0 nxfs-gnumake-0 nxfs-coreutils-0 nxfs-bash-0 nxfs-tar-0 nxfs-sed-0 nxfs-grep-0 nxfs-gawk-0 nxfs-libxcrypt-0 nxfs-findutils-0 nxfs-diffutils-0"

for subdir in $stage0pkgs; do
    pushd $subdir
    (cd stage0 && rm -rf build && make unpackclean)
    popd
done
