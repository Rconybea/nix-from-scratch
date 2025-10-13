{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  toolchain           = nxfsenv.toolchain.toolchain;
in

derivation {
  name               = "gcc-stage1-wrapper-2";
  system             = builtins.currentSystem;

  inherit toolchain;
  inherit (nxfsenv) glibc coreutils gnused;
  bash               = nxfsenv.shell;
  sed                = nxfsenv.gnused;

  builder            = "${nxfsenv.shell}/bin/bash";
  args               = [ ./builder.sh ];

  gcc_wrapper_script = ./gcc-wrapper.sh;
  gxx_wrapper_script = ./gxx-wrapper.sh;

  gcc                = "${toolchain}/bin/gcc";
  gxx                = "${toolchain}/bin/g++";
  gcc_specs          = "${toolchain}/nix-support/gcc-specs";
}
