let
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-gnumake-1     = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-gawk-1        = import ../../bootstrap-1/nxfs-gawk-1/default.nix;
  nxfs-gzip-1        = import ../../bootstrap-1/nxfs-gzip-1/default.nix;

  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-ncurses-2";

  system       = builtins.currentSystem;

  toolchain    = nxfs-toolchain-1;
  coreutils    = nxfs-coreutils-1;
  gzip         = nxfs-gzip-1;
  gnumake      = nxfs-gnumake-1;
  gawk         = nxfs-gawk-1;
  bash         = nxfs-bash-1;

  tar          = nxfs-tar-2;
  grep         = nxfs-grep-2;
  sed          = nxfs-sed-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;
  gcc_wrapper  = nxfs-toolchain-wrapper-1;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "ncurses-6.5-source";
                                         url = "https://invisible-mirror.net/archives/ncurses/ncurses-6.5.tar.gz";
                                         sha256 = "0qnh977jny6mmw045if1imrdlf8n0nsbv79nxxlx9sgai4mpkn0n"; };
}
