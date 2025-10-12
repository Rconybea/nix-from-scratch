{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "9.5";
in

nxfsenv.mkDerivation {
  name         = "nxfs-coreutils-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "coreutils-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/coreutils/coreutils-${version}.tar.xz";
                                         sha256 = "0250l3qc7w4l2lx2ws4wqsd2g2g2q0g6w32d9r7d9pgwqmrj2nkh"; };
}
