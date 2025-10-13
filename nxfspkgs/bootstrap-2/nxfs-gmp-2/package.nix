{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "6.3.0";

in

nxfsenv.mkDerivation {
  name         = "nxfs-gmp-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) m4 file coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gmp-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gmp/gmp-${version}.tar.xz";
                                         sha256 = "1kc3dy4jxand0y118yb9715g9xy1fnzqgkwxy02vd57y2fhg2pcw"; };
}
