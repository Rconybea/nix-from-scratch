{
  # nxfsenv :: attrset
  nxfsenv,
  # gmp :: derivation
  gmp
} :

let
  version = "4.2.1";

in

nxfsenv.mkDerivation {
  name         = "nxfs-mpfr-2";

  system       = builtins.currentSystem;

  inherit gmp;
  inherit (nxfsenv) m4 coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "mpfr-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/mpfr/mpfr-${version}.tar.xz";
                                         sha256 = "1irpgc9aqyhgkwqk7cvib1dgr5v5hf4m0vaaknssyfpkjmab9ydq"; };
}
