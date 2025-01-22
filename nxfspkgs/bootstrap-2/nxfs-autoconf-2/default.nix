let
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;
  nxfs-m4-2          = import ../nxfs-m4-2/default.nix;
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;
  nxfs-perl-2        = import ../nxfs-perl-2/default.nix;
  nxfs-coreutils-2   = import ../nxfs-coreutils-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
in

derivation {
  name         = "nxfs-autoconf-2";

  system       = builtins.currentSystem;

  m4           = nxfs-m4-2;
  gnumake      = nxfs-gnumake-2;
  bash         = nxfs-bash-2;
  sed          = nxfs-sed-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  tar          = nxfs-tar-2;
  gnused       = nxfs-sed-2;
  gawk         = nxfs-gawk-2;
  grep         = nxfs-grep-2;
  perl         = nxfs-perl-2;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  #src         = nxfs-sed-source;
  src          = builtins.fetchTarball { name = "autoconf-2.72-source";
                                         url = "https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz";
                                         sha256 = "1r3922ja9g5ziinpqxgfcc51jhrxvjqnrmc5054jgskylflxc1fp"; };

  target_tuple ="x86_64-pc-linux-gnu";
}
