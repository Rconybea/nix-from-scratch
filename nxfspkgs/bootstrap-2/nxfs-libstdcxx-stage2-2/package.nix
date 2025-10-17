{
  # nxfsenv :: attrset
  nxfsenv,
  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
  # glibc :: derivation
  glibc
} :

let
  nxfs-defs                 = import ../nxfs-defs.nix;
in

let
  # TODO: verify wrapper propagates version
  version = nxfsenv.gcc.version;
in

# PLAN
#   - building with stage2 gcc
#   - using glibc compiled within nix by imported gcc
#
nxfsenv.mkDerivation {
  name         = "nxfs-libstdcxx-stage2-2";
  version      = version;

  system       = builtins.currentSystem;

  inherit mpc mpfr gmp glibc;
  inherit (nxfsenv) binutils texinfo bison flex m4 coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.gcc;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gcc-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
                                         sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                                       };

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;
}
