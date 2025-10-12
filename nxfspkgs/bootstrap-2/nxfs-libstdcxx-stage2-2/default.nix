let
  nxfs-binutils-2           = import ../nxfs-binutils-2;
  nxfs-mpc-2                = import ../nxfs-mpc-2;
  nxfs-mpfr-2               = import ../nxfs-mpfr-2;
  nxfs-gmp-2                = import ../nxfs-gmp-2;
  nxfs-bison-2              = import ../nxfs-bison-2;
  nxfs-flex-2               = import ../nxfs-flex-2;
  nxfs-texinfo-2            = import ../nxfs-texinfo-2;
  nxfs-m4-2                 = import ../nxfs-m4-2;
  nxfs-gnumake-2            = import ../nxfs-gnumake-2;
  nxfs-coreutils-2          = import ../nxfs-coreutils-2;
  nxfs-bash-2               = import ../nxfs-bash-2;
  nxfs-tar-2                = import ../nxfs-tar-2;
  nxfs-gawk-2               = import ../nxfs-gawk-2;
  nxfs-grep-2               = import ../nxfs-grep-2;
  nxfs-sed-2                = import ../nxfs-sed-2;
  nxfs-findutils-2          = import ../nxfs-findutils-2;
  nxfs-diffutils-2          = import ../nxfs-diffutils-2;

  nxfs-gcc-stage2-wrapper-2 = import ../nxfs-gcc-stage2-wrapper-2;
  nxfs-gcc-stage1-2         = import ../nxfs-gcc-stage1-2;
  nxfs-glibc-stage1-2       = import ../nxfs-glibc-stage1-2;

  nxfs-toolchain-1          = import ../../bootstrap-1/nxfs-toolchain-1;

  nxfs-defs                 = import ../nxfs-defs.nix;
in

let
  version = nxfs-gcc-stage1-2.version;
in

# PLAN
#   - building with stage2 gcc
#     compiler expects to use binutils from the external toolchain
#   - using glibc compiled within nix by imported gcc
#   - in this derivation preparing a compiler that, *when run*,
#     will use binutils from nxfs-binutils-2
#
derivation {
  name         = "nxfs-libstdcxx-stage2-2";
  version      = version;

  system       = builtins.currentSystem;

  glibc        = nxfs-glibc-stage1-2;

  toolchain    = nxfs-toolchain-1;

  binutils     = nxfs-binutils-2;
  mpc          = nxfs-mpc-2;
  mpfr         = nxfs-mpfr-2;
  gmp          = nxfs-gmp-2;
  texinfo      = nxfs-texinfo-2;
  bison        = nxfs-bison-2;
  flex         = nxfs-flex-2;
  m4           = nxfs-m4-2;
  coreutils    = nxfs-coreutils-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  grep         = nxfs-grep-2;
  sed          = nxfs-sed-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;
  gcc_wrapper  = nxfs-gcc-stage2-wrapper-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gcc-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
                                         sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                                       };

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;
}
