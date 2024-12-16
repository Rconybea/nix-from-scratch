let
  nxfs-tar-1         = import ../../bootstrap-1/nxfs-tar-1/default.nix;

  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;

in

derivation {
  name         = "nxfs-tar-2";

  system       = builtins.currentSystem;

  bash         = nxfs-bash-1;
  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-1;
  tar          = nxfs-tar-1;

  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  sed          = nxfs-sed-2;
  grep         = nxfs-grep-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  #src         = nxfs-sed-source;
  src          = builtins.fetchTarball { name = "tar-1.35-source";
                                         url = "https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz";
                                         sha256 = "0cmdg6gq9v04631lfb98xg45la1b0y9r5wyspn97ri11krdlyfqz"; };

  target_tuple ="x86_64-pc-linux-gnu";
}
