let
  nxfs-gawk-2        = import ../../bootstrap-2/nxfs-gawk-2/default.nix;

  nxfs-bash-3        = import ../nxfs-bash-3/default.nix;
  nxfs-tar-3         = import ../nxfs-tar-3/default.nix;
  nxfs-grep-3        = import ../nxfs-grep-3/default.nix;
  nxfs-sed-3         = import ../nxfs-sed-3/default.nix;
  nxfs-findutils-3   = import ../nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;
  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;
  nxfs-binutils-2    = import ../../bootstrap-2/nxfs-binutils-2/default.nix;
 
  nxfs-gnumake-2     = import ../../bootstrap-2/nxfs-gnumake-2/default.nix;
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;

  nxfs-system-3      = import ../../bootstrap-3/nxfs-system-3/default.nix;
  nxfs-defs          = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-gawk-3";
  system       = builtins.currentSystem;

  gnumake      = nxfs-gnumake-2;
  bash         = nxfs-bash-3;
  coreutils    = nxfs-coreutils-2;
  tar          = nxfs-tar-3;
  gawk         = nxfs-gawk-2;

  grep         = nxfs-grep-3;
  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  glibc        = nxfs-glibc-stage1-2;
  binutils     = nxfs-binutils-2;

  # source code for nxfs_system() = nix-centric re-implementation of system()
  nxfs_system  = nxfs-system-3;

  builder      = "${nxfs-bash-3}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gawk-5.3.0-source";
                                         url = "https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz";
                                         sha256 = "03fsh86d3jbafmbhm1n0rx8wzsbvlfmpdscfx85dqx6isyk35sd9"; };

  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;
}
