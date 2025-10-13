{
  # nxfsenv :: attrset
  nxfsenv,
  # gcc-unwrapped :: derivation
  gcc-unwrapped,
  # libstdcxx :: derivation
  libstdcxx
} :

let
  version = gcc-unwrapped.version;
in

nxfsenv.mkDerivation {
  name = "gcc-stage3-wrapper-2";
  version = version;
  cxx_version = version;

  system = builtins.currentSystem;

  inherit libstdcxx;
  inherit (nxfsenv) coreutils glibc;
  bash = nxfsenv.shell;
  sed = nxfsenv.gnused;

  builder = "${nxfsenv.shell}/bin/bash";
  args = [ ./builder.sh ];

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc = gcc-unwrapped;

  target_tuple = nxfsenv.nxfs-defs.target_tuple;
}
