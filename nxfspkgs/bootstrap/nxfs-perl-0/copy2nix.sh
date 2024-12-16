#1/bin/bash
#
# Require:
# 1. nxfs-sysroot  [$HOME/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot]
# 2. sysroot installed to nix store [nxfspkgs/bootstrap/nxfs-sysroot-0]
#
# Use
#   build package
#   $ cd nxfspkgs/bootstrap/nxfs-perl-0 && make compile && make install
#   upload to nix store as fixed-output derivation
#   $ cd nxfspkgs/bootstrap/nxfs-perl-0 && ./copy2nix.sh
#   verify success.  should immediately return store path
#   (if nix tries to build, something wrong).
#   $ nix-build

set -e

name=perl
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
# automatically created by nxfspkgs/bootstrap/nxfs-perl-0/copy2nix.sh -- DO NOT EDIT

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
