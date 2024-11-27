# fixed-output derivation.
#
# As of 23nov2024, nix cannot build this derivation.
# Build it outside nix,  then import it directly into the nix store
#
# To build:
#   will be using toolchain built by crosstool-ng.
#
#   Preparation
#   - supporting deps for {nix, crosstool-ng} built locally,
#     using https://github.com/rconybea/nix-from-scratch
#     See nix-from-scratch/.github/workflows/main.yml for possible build sequence
#
#   - nix          in nix-from-scratch/pkgs/nix
#     Assuming nix installed to ~/nixroot:
#     1. nix binariess in ~/nixroot/bin
#     2. nix store     in ~/nixroot/nix/store
#
#   - crosstool-ng in nix-from-scratch/pkgs/crosstool-ng
#   - configuration for crosstool-ng nix-from-scratch/crosstool/.config
#
#   - build toolchain
#     $ cd nix-from-scratch/croostool
#     $ ct-ng build
#
#   Intended use case is in stdenv-bootstrap from empty nix store,
#   For example to use nix on a host where none of the official
#   remedies apply.  Or just because we can.
#
#   Adopt cross-toolchain into nix store directly.
#   Assuming cross toolchain installed to ~/nxfs-toolchain:
#
#   1. establish hash
#       $ nix-hash --type sha256 --base32 ~/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot
#       07c26hwv5wg2xcmjfd02vihpmk5ymgnv6b5dvcz4mc0k976rvdi4  # (roly-desktop-23)
#
#     (expect hash results to differ depending on exact contents of /lib etc)
#
#   2. adopt toolchain into nix store
#       $ nix store add --hash-algo sha256 ~/nxfs-toolchain/x86_64-pc-linux-gnu/sysroot
#       /home/roland/nixroot/nix/store/3hxbb31dh1xkipqy7jnp9k4kkf9lh1mc-sysroot # (roly-desktop-23)
#
#     Substitute hash from step 1 in outputHash = "<hash>" below
#       $ ls -d ~/nixroot/nix/store/*nxfs-toolchain
#
#   3. 'build' it
#
#       $ cd nix-from-scratch/nix-experiments/ex3
#       $ nix-build default.nix
#       $ ls result
#       bin  build.log.bz2  etc  include  lib  libexec  share  x86_64-pc-linux-gnu
#       $ ls l ~/nixroot/nix/store/*nxfs-toolchain.drv
#       /home/roland/nixroot/nix/store/5wh5s3abc7v2zh7fp4961f40hbv89ni6-nxfs-toolchain.drv
#
#     Can pretty-print the store derivation, will see a few details attached
#       $ nix derivation show $(ls -d ~/nixroot/nix/store/*nxfs-toolchain.drv)
#
derivation {
  name = "nxfs-sysroot";
  system = "x86_64-linux";
  builder = ./builder.sh;
  buildInputs = [];
  outputHashAlgo = "sha256";
  outputHash = "07c26hwv5wg2xcmjfd02vihpmk5ymgnv6b5dvcz4mc0k976rvdi4"; # roly-desktop-23
  #outputHash = "0ikk2kh429gfjm8cb17hjqj19zsjjr8fn29gjls9mrjpk92z8wsx";
  #outputHash = "0nk5cnsbw59pdm1rjpgj5wk0a9dbwiw81jvkyaid9g45hnz19wvi";
  outputHashMode = "recursive";
}
