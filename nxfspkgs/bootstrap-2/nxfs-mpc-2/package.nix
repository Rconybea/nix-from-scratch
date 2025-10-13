{
  # nxfsenv :: attrset
  nxfsenv,
  # gmp :: derivation
  gmp,
  # mpfr :: derivation
  mpfr
} :

let
  version = "1.3.1";

in

nxfsenv.mkDerivation {
  name         = "nxfs-mpc-2";

  system       = builtins.currentSystem;

  inherit gmp mpfr;
  inherit (nxfsenv) m4 file coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "mpc-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/mpc/mpc-${version}.tar.gz";
                                         sha256 = "1b6layaybj039fajx8dpy2zvcfy7s02y3y4lficz16vac0fsd0jk";
                                       };
}
