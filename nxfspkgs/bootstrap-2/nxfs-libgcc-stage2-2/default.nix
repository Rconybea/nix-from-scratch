let
  nxfs-binutils-2    = import ../nxfs-binutils-2/default.nix;
  nxfs-mpc-2         = import ../nxfs-mpc-2/default.nix;
  nxfs-mpfr-2        = import ../nxfs-mpfr-2/default.nix;
  nxfs-gmp-2         = import ../nxfs-gmp-2/default.nix;
  nxfs-bison-2       = import ../nxfs-bison-2/default.nix;
  nxfs-flex-2        = import ../nxfs-flex-2/default.nix;
  nxfs-texinfo-2     = import ../nxfs-texinfo-2/default.nix;
  nxfs-m4-2          = import ../nxfs-m4-2/default.nix;
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;
  nxfs-coreutils-2   = import ../nxfs-coreutils-2/default.nix;
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2;

#  nxfs-libstdcxx-stage2-2 = import ../nxfs-libxstdcxx-stage2-2;
  nxfs-glibc-stage1-2 = import ../nxfs-glibc-stage1-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;

  version = "14.2.0";
in

derivation {
  name         = "nxfs-libgcc-stage2-2";

  system       = builtins.currentSystem;

  glibc        = nxfs-glibc-stage1-2;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

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
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gcc-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
                                         sha256 = "1bdp6l9732316ylpzxnamwpn08kpk91h7cmr3h1rgm3wnkfgxzh9";
                                       };

  version      = version;

  target_tuple = nxfs-defs.target_tuple;
}
