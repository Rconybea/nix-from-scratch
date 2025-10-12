#!/bin/bash
#
# Require:
# 1. nxfs_sysroot      [$HOME/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot]
#
# Use
#   $ cd nxfspkgs/bootstrap/nxfs-sysroot-0
#   $ ./coppy2nix.sh

set -euo pipefail

# provides
#   NIX_PREFIX
#   NXFS_TOOLCHAIN_PREFIX
#   NXFS_HOST_TUPLE
#   NXFS_MAX_JOBS
#
source ../nxfs-vars.sh

nxfs_toolchain_name=$(basename ${NXFS_TOOLCHAIN_PREFIX})

# capture a few breadcrumbs for convenience of downstream derivations
# that bootstrap from the toolchain being imported here.
#
# In stage0 we can get these from nxfs-vars.sh
# In stage1 need to get them from nix store
# In stage2 we aim for fixpoint that's independent of all these values
# excepting NXFS_HOST_TUPLE
#
#
mkdir -p ${NXFS_TOOLCHAIN_PREFIX}/nix-support

cat > ${NXFS_TOOLCHAIN_PREFIX}/nix-support/nxfs-host-tuple <<EOF
${NXFS_HOST_TUPLE}
EOF

cat > ${NXFS_TOOLCHAIN_PREFIX}/nix-support/nxfs-toolchain-prefix <<EOF
${NXFS_TOOLCHAIN_PREFIX}
EOF

# e.g. ld-linux-x86-64.so.2
dynamic_linker_name=$(basename $(readlink -f ${NXFS_TOOLCHAIN_PREFIX}/bin/ld.so))

cat > ${NXFS_TOOLCHAIN_PREFIX}/nix-support/dynamic-linker-name <<EOF
${dynamic_linker_name}
EOF

# We may have introduced a gcc specs file under ${NXFS_TOOLCHAIN_PREFIX}.
# That's counterproductive within nix store.
# Dump compiled-in specs file here so we can reflect it back to gcc
# (i.e. gcc -specs path/to/file) in remainder of bootstrap.
#
${NXFS_TOOLCHAIN_PREFIX}/bin/gcc -dumpspecs > ${NXFS_TOOLCHAIN_PREFIX}/nix-support/gcc-specs

# establish output hash for target dir tree
#
declare target_sha256
target_sha256=$(nix-hash --type sha256 --base32 ${NXFS_TOOLCHAIN_PREFIX})

# add target dir tree to nix store
#
# works w/ nix 2.24:
nix store add --hash-algo sha256 ${NXFS_TOOLCHAIN_PREFIX}
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
