let
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;

  gcc = "${nxfs-toolchain-1}/bin/x86_64-pc-linux-gnu-gcc";

in

derivation {
  name = "conftest-1";
  system = builtins.currentSystem;

  toolchain = nxfs-toolchain-1;
  coreutils = nxfs-coreutils-1;
  bash = nxfs-bash-1;
  #gcc = gcc;

  builder = "${nxfs-bash-1}/bin/bash";
  args = [ ./builder.sh ];

  src = ./conftest.c;

  program = "conftest";
  target_tuple="x86_64-pc-linux-gnu";
}
