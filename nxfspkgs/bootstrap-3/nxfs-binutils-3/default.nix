let
  nxfs-binutils-2    = import ../../bootstrap-2/nxfs-binutils-2/default.nix;
  nxfs-pkgconf-3     = import ../nxfs-pkgconf-3/default.nix;
  nxfs-libxcrypt-3   = import ../nxfs-libxcrypt-3/default.nix;
  nxfs-coreutils-3   = import ../nxfs-coreutils-3/default.nix;
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

  version = "2.43.1";
in

derivation {
  name         = "nxfs-binutils-3";

  system       = builtins.currentSystem;

  #toolchain    = nxfs-toolchain-1;
  #sysroot      = nxfs-sysroot-1;
  binutils     = nxfs-binutils-2;
  pkgconf      = nxfs-pkgconf-3;
  libxcrypt    = nxfs-libxcrypt-3;
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

  src          = builtins.fetchTarball { name = "binutils-${version}-source";
                                         url = "https://sourceware.org/pub/binutils/releases/binutils-${version}.tar.xz";
                                         sha256 = "1z0lq9ia19rw1qk09i3im495s5zll7xivdslabydxl9zlp3wy570"; };

  target_tuple = nxfs-defs.target_tuple;
}
