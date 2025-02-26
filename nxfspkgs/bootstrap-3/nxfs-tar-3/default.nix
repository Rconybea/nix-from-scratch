let
  nxfs-tar-2         = import ../../bootstrap-2/nxfs-tar-2/default.nix;
  nxfs-gnumake-2     = import ../../bootstrap-2/nxfs-gnumake-2/default.nix;
  nxfs-gawk-2        = import ../../bootstrap-2/nxfs-gawk-2/default.nix;

  nxfs-grep-3        = import ../nxfs-grep-3/default.nix;
  nxfs-sed-3         = import ../nxfs-sed-3/default.nix;
  nxfs-findutils-3   = import ../nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;
  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;
  nxfs-binutils-2    = import ../../bootstrap-2/nxfs-binutils-2/default.nix;

  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-bash-2        = import ../../bootstrap-2/nxfs-bash-2/default.nix;

  nxfs-defs          = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-tar-3";

  system       = builtins.currentSystem;

  bash         = nxfs-bash-2;
  coreutils    = nxfs-coreutils-2;
  tar          = nxfs-tar-2;

  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  grep         = nxfs-grep-3;
  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  glibc        = nxfs-glibc-stage1-2;
  binutils     = nxfs-binutils-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  #src         = nxfs-sed-source;
  src          = builtins.fetchTarball { name = "tar-1.35-source";
                                         url = "https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz";
                                         sha256 = "0cmdg6gq9v04631lfb98xg45la1b0y9r5wyspn97ri11krdlyfqz"; };

  target_tuple = nxfs-defs.target_tuple;
}
