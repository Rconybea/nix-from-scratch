let
  nxfs-gawk-1         = import ../../bootstrap-1/nxfs-gawk-1/default.nix;

  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;

  nxfs-gnumake-1     = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;

  nxfs-popen-2       = import ../nxfs-popen-2/default.nix;
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-defs = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-gawk-2";
  system       = builtins.currentSystem;

  gnumake      = nxfs-gnumake-1;
  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-1;
  gawk         = nxfs-gawk-1;
  # popen: source code for nxfs_system() = nix-centric re-implementation of system(),popen()
  popen        = nxfs-popen-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  grep         = nxfs-grep-2;
  sed          = nxfs-sed-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;
  gcc_wrapper  = nxfs-toolchain-wrapper-1;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gawk-5.3.0-source";
                                         url = "https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz";
                                         sha256 = "03fsh86d3jbafmbhm1n0rx8wzsbvlfmpdscfx85dqx6isyk35sd9"; };

  # nix-build -A source
  outputs      = [ "out" "source" ];

  target_tuple = nxfs-defs.target_tuple;
}
