let
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;

  gcc = "${nxfs-toolchain-1}/bin/x86_64-pc-linux-gnu-gcc";
  mkdir = "${nxfs-coreutils-1}/bin/mkdir";
  bash = "${nxfs-bash-1}/bin/bash";

in

derivation {
  name = "hello-1";
  system = builtins.currentSystem;

  gcc = gcc;
  mkdir = mkdir;
  bash = bash;

  builder = bash;
  args = [ ./builder.sh ];

  src = ./hello.c;
}
