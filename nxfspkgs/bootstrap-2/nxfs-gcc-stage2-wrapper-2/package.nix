{
  nxfsenv
} :

let
  # unwrapped gcc
  gcc = nxfsenv.gcc-x1;

  nxfs-defs = import ../nxfs-defs.nix;
in

nxfsenv.mkDerivation {
  name = "gcc-stage2-wrapper-2";
  version = gcc.version;
  system = builtins.currentSystem;

  inherit gcc;
  inherit (nxfsenv) coreutils glibc;
  bash = nxfsenv.shell;
  sed = nxfsenv.gnused;
  gnused = nxfsenv.gnused;

  builder = "${nxfsenv.shell}/bin/bash";
  args = [ ./builder.sh ];

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  target_tuple = nxfs-defs.target_tuple;
}
