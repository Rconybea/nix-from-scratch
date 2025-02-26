let
  nxfs-sed-1 = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1 = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-defs = import ../nxfs-defs.nix;
in


derivation {
  name = "toolchain-wrapper-1";
  system = builtins.currentSystem;

  bash = nxfs-bash-1;
  sed = nxfs-sed-1;
  toolchain = nxfs-toolchain-1;
  sysroot = nxfs-sysroot-1;
  coreutils = nxfs-coreutils-1;
  gnused = nxfs-sed-1;

  builder = "${nxfs-bash-1}/bin/bash";
  args = [ ./builder.sh ];

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc = "${nxfs-toolchain-1}/bin/${nxfs-defs.target_tuple}-gcc";
  gxx = "${nxfs-toolchain-1}/bin/${nxfs-defs.target_tuple}-g++";

  target_tuple=nxfs-defs.target_tuple;
}
