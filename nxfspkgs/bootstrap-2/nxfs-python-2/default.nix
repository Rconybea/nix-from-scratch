let

  nxfs-zlib-2        = import ../nxfs-zlib-2/default.nix;
  nxfs-coreutils-2   = import ../nxfs-coreutils-2/default.nix;
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-python-2";

  system       = builtins.currentSystem;

  zlib         = nxfs-zlib-2;
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
  gcc_wrapper  = nxfs-toolchain-wrapper-1;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  #src         = nxfs-sed-source;
  src          = builtins.fetchTarball { name = "python-3.12.6-source";
                                         url = "https://www.python.org/ftp/python/3.12.6/Python-3.12.6.tar.xz";
                                         sha256 = "0ggdm1l4dhr3qn0rwzjha5r15m3mfyl0hj8j89xip7jx10mip952"; };

  target_tuple = nxfs-defs.target_tuple;
}
