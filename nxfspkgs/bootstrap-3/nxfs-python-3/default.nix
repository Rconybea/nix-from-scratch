let

  nxfs-binutils-3    = import ../nxfs-binutils-3/default.nix;
  nxfs-zlib-3        = import ../nxfs-zlib-3/default.nix;
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

  #nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  #nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;

  version = "3.12.6";
in

derivation {
  name         = "nxfs-python-3";

  system       = builtins.currentSystem;

  binutils     = nxfs-binutils-3;
  zlib         = nxfs-zlib-3;
  coreutils    = nxfs-coreutils-3;
  bash         = nxfs-bash-3;
  tar          = nxfs-tar-3;
  gnumake      = nxfs-gnumake-3;
  gawk         = nxfs-gawk-3;
  grep         = nxfs-grep-3;
  gnused       = nxfs-sed-3;
  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  #toolchain    = nxfs-toolchain-1;
  #sysroot      = nxfs-sysroot-1;

  builder      = "${nxfs-bash-3}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "python-${version}-source";
                                         url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
                                         sha256 = "0ggdm1l4dhr3qn0rwzjha5r15m3mfyl0hj8j89xip7jx10mip952"; };

  target_tuple = nxfs-defs.target_tuple;
}
