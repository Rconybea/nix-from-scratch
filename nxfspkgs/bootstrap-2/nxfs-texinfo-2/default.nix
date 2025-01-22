let
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;

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
  name         = "nxfs-texinfo-2";

  system       = builtins.currentSystem;

  automake     = nxfs-automake-2;
  autoconf     = nxfs-autoconf-2;
  m4           = nxfs-m4-2;
  perl         = nxfs-perl-2;
  file         = nxfs-file-2;
  coreutils    = nxfs-coreutils-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  grep         = nxfs-grep-2;
  gnused       = nxfs-sed-2;
  sed          = nxfs-sed-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  #src         = nxfs-sed-source;
  src          = builtins.fetchTarball { name = "texinfo-6.7-source";
                                         url = "https://ftp.gnu.org/gnu/texinfo/texinfo-6.7.tar.xz";
                                         sha256 = "0bgzsh574c3qh0s5mbq7iyrd5zfh3x431719yzch7jjg28kidm6r"; };

  target_tuple ="x86_64-pc-linux-gnu";
}
