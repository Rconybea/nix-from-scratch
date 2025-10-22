let
  nxfs-bintools-x0-wrapper-1 = import ../nxfs-binutils-x0-wrapper-1/package.nix;
  nxfs-gnused-1 = import ../nxfs-sed-1/default.nix;
  nxfs-toolchain-1 = import ../nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1 = import ../nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../nxfs-bash-1/default.nix;
  nxfs-defs = import ../nxfs-defs.nix;
in


derivation {
  name = "toolchain-wrapper-1";
  system = builtins.currentSystem;

  # want to support the following structure for stdenv:
  #   stdenv.cc           (this wrapper)
  #   stdenv.cc.cc        unwrapped c/c++ compiler
  #   stdenv.cc.bintools  *wrapped* bintools
  #   stdenv.cc.libc      glibc (same as stdenv.cc.cc in stage1)
  #   stdenv.cc.version   gcc version. prioritize (vs {binutils,glibc})
  #                       because needed for downstream wrapper include paths
  #
  cc = nxfs-toolchain-1;
  version = nxfs-toolchain-1.version;  # e.g. "14.2.0"
  bintools = nxfs-bintools-x0-wrapper-1;
  libc = nxfs-toolchain-1;

  bash = nxfs-bash-1;
  sed = nxfs-gnused-1;
  toolchain = nxfs-toolchain-1;
  coreutils = nxfs-coreutils-1;
  gnused = nxfs-gnused-1;

  builder = "${nxfs-bash-1}/bin/bash";
  args = [ ./builder.sh ];

  setup_hook = ./setup-hook.sh;
  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc = "${nxfs-toolchain-1}/bin/gcc";
  gxx = "${nxfs-toolchain-1}/bin/g++";
  gcc_specs = "${nxfs-toolchain-1}/nix-support/gcc-specs";

  target_tuple=nxfs-defs.target_tuple;
}
