{
  # nxfsenv :: attrset
  nxfsenv
} :

nxfsenv.mkDerivation {
  name = "gcc-wrapper-2";
  system = builtins.currentSystem;

  glibc = nxfsenv.glibc;
  cxx_version = "14.2.0";

  bash = nxfsenv.shell;
  sed = nxfsenv.gnused;
  coreutils = nxfsenv.coreutils;

  builder = "${nxfsenv.shell}/bin/bash";
  args = [ ./builder.sh ];

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc = nxfsenv.gcc-unwrapped;

  target_tuple = nxfsenv.nxfs-defs.target_tuple;
}
