let
  nxfs-gcc-stage1-2 = import ../nxfs-gcc-stage1-2/default.nix;
  nxfs-glibc-stage1-2 = import ../nxfs-glibc-stage1-2/default.nix;
  nxfs-libstdcxx-stage2-2 = import ../nxfs-libstdcxx-stage2-2/default.nix;

  nxfs-sed-1 = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;
in

let
  version = nxfs-gcc-stage1-2.version;
in

derivation {
  name = "gcc-stage3-wrapper-2";
  version = version;
  cxx_version = version;

  system = builtins.currentSystem;

  glibc = nxfs-glibc-stage1-2;
  libstdcxx = nxfs-libstdcxx-stage2-2;

  bash = nxfs-bash-1;
  sed = nxfs-sed-1;
#  toolchain = nxfs-toolchain-1;
  coreutils = nxfs-coreutils-1;
#  gnused = nxfs-sed-1;

  builder = "${nxfs-bash-1}/bin/bash";
  args = [ ./builder.sh ];

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc = nxfs-gcc-stage1-2;

  target_tuple = nxfs-defs.target_tuple;
}
