let
  nxfs-gawk-1         = import ../../bootstrap-1/nxfs-gawk-1/default.nix;

  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;

  nxfs-gnumake-1     = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-tar-1         = import ../../bootstrap-1/nxfs-tar-1/default.nix;
  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;

in

derivation {
  name         = "gawk";
  system       = builtins.currentSystem;

  gnumake      = nxfs-gnumake-1;
  bash         = nxfs-bash-1;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-1;
  tar          = nxfs-tar-1;
  gawk         = nxfs-gawk-1;
  sed          = nxfs-sed-2;
  grep         = nxfs-grep-2;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  #src         = nxfs-sed-source;
  src          = builtins.fetchTarball { url = "https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz"; };

  target_tuple ="x86_64-pc-linux-gnu";
}
