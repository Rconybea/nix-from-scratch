let
  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1;
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1;

  mkdir = "${nxfs-coreutils-1}/bin/mkdir";
  bash = "${nxfs-bash-1}/bin/bash";

in

derivation {
  name = "hello-1";
  system = builtins.currentSystem;

  gcc_specs = "${nxfs-toolchain-1}/lib/gcc/x86_64-pc-linux-gnu/specs";

  mkdir = mkdir;
  bash = bash;

  builder = bash;
  args = [ ./builder.sh ];

  toolchain_wrapper = nxfs-toolchain-wrapper-1;
  toolchain = nxfs-toolchain-1;
  coreutils = nxfs-coreutils-1;

  src = ./hello.cpp;
}
