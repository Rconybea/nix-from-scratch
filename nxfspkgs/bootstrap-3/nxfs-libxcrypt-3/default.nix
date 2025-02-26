let
  nxfs-perl-2        = import ../../bootstrap-2/nxfs-perl-2/default.nix;
  nxfs-coreutils-3   = import ../nxfs-coreutils-3/default.nix;

  nxfs-binutils-2    = import ../../bootstrap-2/nxfs-binutils-2/default.nix;
  nxfs-bash-3        = import ../nxfs-bash-3/default.nix;
  nxfs-tar-3         = import ../nxfs-tar-3/default.nix;
  nxfs-gnumake-3     = import ../nxfs-gnumake-3/default.nix;
  nxfs-gawk-3        = import ../nxfs-gawk-3/default.nix;
  nxfs-grep-3        = import ../nxfs-grep-3/default.nix;
  nxfs-sed-3         = import ../nxfs-sed-3/default.nix;
  nxfs-findutils-3   = import ../nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;

#  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
#  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;

  version = "4.4.36";
in

derivation {
  name         = "nxfs-libxcrypt-3";

  system       = builtins.currentSystem;

  perl         = nxfs-perl-2;
  coreutils    = nxfs-coreutils-3;
  binutils     = nxfs-binutils-2;
  bash         = nxfs-bash-3;
  tar          = nxfs-tar-3;
  gnumake      = nxfs-gnumake-3;
  gawk         = nxfs-gawk-3;
  grep         = nxfs-grep-3;
  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  #toolchain    = nxfs-toolchain-1;
 # sysroot      = nxfs-sysroot-1;

  builder      = "${nxfs-bash-3}/bin/bash";
  args         = [ ./builder.sh ];

  src = builtins.fetchTarball {
    name = "libxcrypt-${version}-source";
    url = "https://github.com/besser82/libxcrypt/releases/download/v${version}/libxcrypt-${version}.tar.xz";
    sha256 = "1iflya5d4ndgjg720p40x19c1j2g72zn64al8f74x3h4bnapqx1d";
  };
  target_tuple = nxfs-defs.target_tuple;
}
