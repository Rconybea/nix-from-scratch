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
  nxfs-autoconf-2    = import ../nxfs-autoconf-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
in

derivation {
  name         = "nxfs-automake-2";

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
  autoconf     = nxfs-autoconf-2;
  findutils    = nxfs-findutils-2;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "automake-1.16.5-source";
                                         url = "https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz";
                                         sha256 = "0pac10hgw6r4kbafdbxg7gpb503fq9a9a31r5hvdh95nd2pcngv0"; };

#  src          = builtins.fetchTarball { name = "automake-1.17-source";
#                                         url = "https://ftp.gnu.org/gnu/automake/automake-1.17.tar.xz";
#                                         sha256 = "1nwgz937zikw5avzhvvzf57i917pq0q05s73wqr28abwqxa3bll8"; };

  target_tuple ="x86_64-pc-linux-gnu";
}
