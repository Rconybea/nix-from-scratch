let
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-sysroot-1 = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  mkdir = "${nxfs-coreutils-1}/bin/mkdir";
  bash = "${nxfs-bash-1}/bin/bash";

in

derivation {
  name = "hello-1";
  system = builtins.currentSystem;

  gcc = "x86_64-pc-linux-gnu-gcc";
  mkdir = mkdir;
  bash = bash;

  builder = bash;
  args = [ ./builder.sh ];

  toolchain = nxfs-toolchain-1;
  coreutils = nxfs-coreutils-1;
  sysroot = nxfs-sysroot-1;

  src = ./hello.c;
}
