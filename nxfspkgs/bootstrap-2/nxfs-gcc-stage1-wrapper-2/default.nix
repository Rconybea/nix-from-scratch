let
  nxfs-glibc-stage1-2 = import ../nxfs-glibc-stage1-2;
  nxfs-sed-1          = import ../../bootstrap-1/nxfs-sed-1;
  nxfs-toolchain-1    = import ../../bootstrap-1/nxfs-toolchain-1;
  nxfs-coreutils-1    = import ../../bootstrap-1/nxfs-coreutils-1;
  nxfs-bash-1         = import ../../bootstrap-1/nxfs-bash-1;
  nxfs-defs           = import ../nxfs-defs.nix;
in

let
  target_tuple        = nxfs-defs.target_tuple;
in

derivation {
  name               = "gcc-stage1-wrapper-2";
  system             = builtins.currentSystem;

  glibc              = nxfs-glibc-stage1-2;

  bash               = nxfs-bash-1;
  sed                = nxfs-sed-1;
  toolchain          = nxfs-toolchain-1;
  coreutils          = nxfs-coreutils-1;
  gnused             = nxfs-sed-1;

  builder            = "${nxfs-bash-1}/bin/bash";
  args               = [ ./builder.sh ];

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc                = "${nxfs-toolchain-1}/bin/${target_tuple}-gcc";
  gxx                = "${nxfs-toolchain-1}/bin/${target_tuple}-g++";
  gcc_specs          = "${nxfs-toolchain-1}/nix-support/gcc-specs";

  inherit target_tuple;
}
