let
  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-sed-1 = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-sysroot-1 = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  bash_program = "${nxfs-bash-1}/bin/bash";
in

derivation {
  name = "popen-2";
  system = builtins.currentSystem;

  builder = bash_program;
  args = [ ./builder.sh ];

  toolchain_wrapper = nxfs-toolchain-wrapper-1;
  toolchain = nxfs-toolchain-1;
  bash = nxfs-bash-1;
  sed = nxfs-sed-1;
  coreutils = nxfs-coreutils-1;
  sysroot = nxfs-sysroot-1;


  src = ./popen.c;
}
