let
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-gnumake-1     = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-gawk-1        = import ../../bootstrap-1/nxfs-gawk-1/default.nix;

  nxfs-ncurses-2     = import ../nxfs-ncurses-2;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-bash-2";

  system       = builtins.currentSystem;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-1;
  gnumake      = nxfs-gnumake-1;
  gawk         = nxfs-gawk-1;
  bash         = nxfs-bash-1;

  ncurses      = nxfs-ncurses-2;
  tar          = nxfs-tar-2;
  grep         = nxfs-grep-2;
  sed          = nxfs-sed-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;
  gcc_wrapper  = nxfs-toolchain-wrapper-1;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "bash-5.2.32-source";
                                         url = "https://ftp.gnu.org/gnu/bash/bash-5.2.32.tar.gz";
                                         sha256 = "1bhqakwia1zpnq9kgpn7kxsgvgh5b8nysanki0j2m7v7im4yjcvp"; };

  target_tuple = nxfs-defs.target_tuple;
}
