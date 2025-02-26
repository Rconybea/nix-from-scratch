let
  nxfs-gcc-stage2-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-stage2-wrapper-2/default.nix;
  nxfs-gcc-stage1-2 = import ../../bootstrap-2/nxfs-gcc-stage1-2/default.nix;
  nxfs-binutils-2 = import ../../bootstrap-2/nxfs-binutils-2/default.nix;
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-gawk-2 = import ../../bootstrap-2/nxfs-gawk-2/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-sed-1 = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-sysroot-1 = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  mkdir = "${nxfs-coreutils-1}/bin/mkdir";
  bash = "${nxfs-bash-1}/bin/bash";

in

derivation {
  name = "hello-2";
  system = builtins.currentSystem;

  bash = bash;

  builder = bash;
  args = [ ./builder.sh ];

  gcc_wrapper = nxfs-gcc-stage2-wrapper-2;
  gcc = nxfs-gcc-stage1-2;
  binutils = nxfs-binutils-2;
  gawk = nxfs-gawk-2;
  sed = nxfs-sed-1;
  coreutils = nxfs-coreutils-1;
  sysroot = nxfs-sysroot-1;

  src = ./main.c;
}
