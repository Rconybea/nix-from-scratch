let
  nxfs-binutils-3    = import ../nxfs-binutils-3/default.nix;
  nxfs-mpc-3         = import ../nxfs-mpc-3/default.nix;
  nxfs-mpfr-3        = import ../nxfs-mpfr-3/default.nix;
  nxfs-gmp-3         = import ../nxfs-gmp-3/default.nix;
  nxfs-bison-3       = import ../nxfs-bison-3/default.nix;
  nxfs-flex-3        = import ../nxfs-flex-3/default.nix;
  nxfs-texinfo-3     = import ../nxfs-texinfo-3/default.nix;
  nxfs-m4-3          = import ../nxfs-m4-3/default.nix;
  nxfs-gnumake-3     = import ../nxfs-gnumake-3/default.nix;
  nxfs-coreutils-3   = import ../nxfs-coreutils-3/default.nix;
  nxfs-bash-3        = import ../nxfs-bash-3/default.nix;
  nxfs-tar-3         = import ../nxfs-tar-3/default.nix;
  nxfs-gawk-3        = import ../nxfs-gawk-3/default.nix;
  nxfs-grep-3        = import ../nxfs-grep-3/default.nix;
  nxfs-sed-3         = import ../nxfs-sed-3/default.nix;
  nxfs-findutils-3   = import ../nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;

  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;

  #nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;

  version = "14.2.0";
in

# PLAN
#   - building with nxfs-toolchain-1 (redirected crosstool-ng toolchain):
#     compiler expects to use binutils from the crosstool-ng toolchain
#   - in this derivation preparing a compiler that, *when run*,
#     will use binutils from nxfs-binutils-2
#
derivation {
  name         = "nxfs-gcc-3";

  system       = builtins.currentSystem;

  #libstdcxx    = nxfs-libstdcxx-stage2-2;
  glibc        = nxfs-glibc-stage1-2;

  #toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

  binutils     = nxfs-binutils-3;
  mpc          = nxfs-mpc-3;
  mpfr         = nxfs-mpfr-3;
  gmp          = nxfs-gmp-3;
  texinfo      = nxfs-texinfo-3;
  bison        = nxfs-bison-3;
  flex         = nxfs-flex-3;
  m4           = nxfs-m4-3;
  coreutils    = nxfs-coreutils-3;
  bash         = nxfs-bash-3;
  tar          = nxfs-tar-3;
  gnumake      = nxfs-gnumake-3;
  gawk         = nxfs-gawk-3;
  grep         = nxfs-grep-3;
  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-3}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gcc-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
                                         sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                                       };

  target_tuple = nxfs-defs.target_tuple;
}
