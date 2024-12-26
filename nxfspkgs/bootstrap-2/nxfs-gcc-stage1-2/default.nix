let
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-coreutils-2   = import ../nxfs-coreutils-2/default.nix;
  nxfs-binutils-2    = import ../nxfs-binutils-2/default.nix;
  nxfs-autoconf-2    = import ../nxfs-autoconf-2/default.nix;
  nxfs-texinfo-2     = import ../nxfs-texinfo-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

in

# PLAN
#   - building with nxfs-toolchain-1 (redirected crosstool-ng toolchain):
#     compiler expects to use binutils from the crosstool-ng toolchain
#   - in this derivation preparing a compiler that, *when run*,
#     will use binutils from nxfs-binutils-2
#
derivation {
  name         = "nxfs-binutils-2";

  system       = builtins.currentSystem;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

  findutils    = nxfs-findutils-2;
  coreutils    = nxfs-coreutils-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  sed          = nxfs-sed-2;
  grep         = nxfs-grep-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  texinfo      = nxfs-texinfo-2;

  binutils     = nxfs-binutils-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  gcc_src      = builtins.fetchTarball { name = "gcc-14.2.0-source";
                                         url = "https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz";
                                         sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                                       };

  mpfr_src     = builtins.fetchTarball { name = "mpfr-4.2.1-source";
                                         url = "https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz";
                                         sha256 = "1irpgc9aqyhgkwqk7cvib1dgr5v5hf4m0vaaknssyfpkjmab9ydq"; };

  mpc_src      = builtins.fetchTarball { name = "mpc-1.3.1-source";
                                         url = "https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz";
                                         sha256 = "1b6layaybj039fajx8dpy2zvcfy7s02y3y4lficz16vac0fsd0jk"; };

  gmp_src      = builtins.fetchTarball { name = "gmp-6.3.0-source";
                                         url = "https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz";
                                         sha256 = "1kc3dy4jxand0y118yb9715g9xy1fnzqgkwxy02vd57y2fhg2pcw"; };

  target_tuple = "x86_64-pc-linux-gnu";
}
