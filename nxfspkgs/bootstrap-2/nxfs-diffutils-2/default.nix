let
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;

  nxfs-sed-1         = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-grep-1        = import ../../bootstrap-1/nxfs-grep-1/default.nix;
  nxfs-gawk-1        = import ../../bootstrap-1/nxfs-gawk-1/default.nix;
  nxfs-gnumake-1     = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-tar-1         = import ../../bootstrap-1/nxfs-tar-1/default.nix;
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

in

derivation {
  name         = "nxfs-diffutils-2";

  system       = builtins.currentSystem;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

  coreutils    = nxfs-coreutils-1;
  bash         = nxfs-bash-1;
  tar          = nxfs-tar-1;
  gnumake      = nxfs-gnumake-1;
  gawk         = nxfs-gawk-1;
  sed          = nxfs-sed-1;
  grep         = nxfs-grep-1;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "diffutils-3.10-source";
                                         url = "https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz";
                                         sha256 = "13cxlscmjns6dk4yp0nmmyp1ldjkbag68lmgrizcd5dzz00xi8j7"; };

  target_tuple = "x86_64-pc-linux-gnu";
}
