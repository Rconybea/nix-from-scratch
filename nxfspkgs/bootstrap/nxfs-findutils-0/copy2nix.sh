#1/bin/bash
#
# Require:
# 1. nxfs-sysroot  [$HOME/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot]
# 2. sysroot installed to nix store [nxfspkgs/bootstrap/nxfs-sysroot-0]
#
# Use
#   $ cd nxfspkgs/bootstrap/nxfs-findutils-0 && make compile && make install
#   $ cd nxfspkgs/bootstrap/nxfs-findutils-0 && ./copy2nix.sh

set -euo pipefail

# must match basename of PREFIX directory in stage0/ build
stem=findutils
name=nxfs-${stem}-0
uploaddir=./${stem}

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
# automatically created by nxfspkgs/bootstrap/${name}/copy2nix.sh -- DO NOT EDIT

derivation {
  name = "${stem}";
  system = "x86_64-linux";
  builder = ./builder.sh;
  buildInputs = [ ];
  outputHashAlgo = "sha256";
  outputHash = "${target_sha256}";
  outputHashMode = "recursive";
}

EOF
