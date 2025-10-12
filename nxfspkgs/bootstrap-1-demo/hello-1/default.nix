let
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1;

  mkdir = "${nxfs-coreutils-1}/bin/mkdir";
  bash = "${nxfs-bash-1}/bin/bash";

in

derivation {
  name = "hello-1";
  system = builtins.currentSystem;

  gcc = "x86_64-pc-linux-gnu-gcc";
  gcc_specs = "${nxfs-toolchain-1}/lib/gcc/x86_64-pc-linux-gnu/specs";
  mkdir = mkdir;
  bash = bash;

  builder = bash;
  args = [ ./builder.sh ];

  toolchain = nxfs-toolchain-1;
  coreutils = nxfs-coreutils-1;

  src = ./hello.c;
}
