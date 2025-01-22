let
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;

  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;

in

derivation {
  name         = "nxfs-bash-2";

  system       = builtins.currentSystem;

  bash         = nxfs-bash-1;
  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-1;

  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  grep         = nxfs-grep-2;
  sed          = nxfs-sed-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "bash-5.2.32-source";
                                         url = "https://ftp.gnu.org/gnu/bash/bash-5.2.32.tar.gz";
                                         sha256 = "1bhqakwia1zpnq9kgpn7kxsgvgh5b8nysanki0j2m7v7im4yjcvp"; };

  target_tuple ="x86_64-pc-linux-gnu";
}
