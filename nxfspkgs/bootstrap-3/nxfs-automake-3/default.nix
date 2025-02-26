let
  nxfs-autoconf-3    = import ../nxfs-autoconf-3/default.nix;
  nxfs-perl-3        = import ../nxfs-perl-3/default.nix;
  nxfs-m4-3          = import ../nxfs-m4-3/default.nix;
  nxfs-binutils-3    = import ../nxfs-binutils-3/default.nix;
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

  nxfs-defs = import ../nxfs-defs.nix;

  version = "1.16.5";
in

derivation {
  name         = "nxfs-automake-3";

  system       = builtins.currentSystem;

  autoconf     = nxfs-autoconf-3;
  perl         = nxfs-perl-3;
  m4           = nxfs-m4-3;
  binutils     = nxfs-binutils-3;
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

  src          = builtins.fetchTarball { name = "automake-${version}-source";
                                         url = "https://ftp.gnu.org/gnu/automake/automake-${version}.tar.xz";
                                         sha256 = "0pac10hgw6r4kbafdbxg7gpb503fq9a9a31r5hvdh95nd2pcngv0"; };

#  src          = builtins.fetchTarball { name = "automake-1.17-source";
#                                         url = "https://ftp.gnu.org/gnu/automake/automake-1.17.tar.xz";
#                                         sha256 = "1nwgz937zikw5avzhvvzf57i917pq0q05s73wqr28abwqxa3bll8"; };

  target_tuple = nxfs-defs.target_tuple;
}
