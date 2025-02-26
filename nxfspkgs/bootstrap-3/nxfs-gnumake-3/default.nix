let
  nxfs-gnumake-2     = import ../../bootstrap-2/nxfs-gnumake-2/default.nix;

  nxfs-gawk-3        = import ../nxfs-gawk-3/default.nix;
  nxfs-grep-3        = import ../nxfs-grep-3/default.nix;
  nxfs-sed-3         = import ../nxfs-sed-3/default.nix;
  nxfs-findutils-3   = import ../nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;
  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;
  nxfs-binutils-2    = import ../../bootstrap-2/nxfs-binutils-2/default.nix;

  nxfs-tar-3         = import ../nxfs-tar-3/default.nix;
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-bash-3        = import ../nxfs-bash-3/default.nix;

  nxfs-defs          = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-gnumake-3";

  system       = builtins.currentSystem;

  gnumake      = nxfs-gnumake-2;
  bash         = nxfs-bash-3;
  coreutils    = nxfs-coreutils-2;
  tar          = nxfs-tar-3;

  gawk         = nxfs-gawk-3;
  grep         = nxfs-grep-3;
  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  glibc        = nxfs-glibc-stage1-2;
  binutils     = nxfs-binutils-2;

  builder      = "${nxfs-bash-3}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "make-4.4.1-source";
                                         url = "https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz";
                                         sha256 = "141z25axp7iz11sqci8c312zlmcmfy8bpyjpf0b0gfi8ri3kna7q";
                                       };

  target_tuple = nxfs-defs.target_tuple;
}
