let
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;
  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;
  nxfs-binutils-2 = import ../../bootstrap-2/nxfs-binutils-2/default.nix;

  nxfs-sed-2         = import ../../bootstrap-2/nxfs-sed-2/default.nix;
  nxfs-grep-2        = import ../../bootstrap-2/nxfs-grep-2/default.nix;
  nxfs-gawk-2        = import ../../bootstrap-2/nxfs-gawk-2/default.nix;
  nxfs-gnumake-2     = import ../../bootstrap-2/nxfs-gnumake-2/default.nix;
  nxfs-tar-2         = import ../../bootstrap-2/nxfs-tar-2/default.nix;
  nxfs-bash-2        = import ../../bootstrap-2/nxfs-bash-2/default.nix;
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-defs          = import ../nxfs-defs.nix;

in

derivation {
  name         = "nxfs-diffutils-3";

  system       = builtins.currentSystem;

  coreutils    = nxfs-coreutils-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  sed          = nxfs-sed-2;
  grep         = nxfs-grep-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  libc         = nxfs-glibc-stage1-2;
  binutils     = nxfs-binutils-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "diffutils-3.10-source";
                                         url = "https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz";
                                         sha256 = "13cxlscmjns6dk4yp0nmmyp1ldjkbag68lmgrizcd5dzz00xi8j7"; };

  target_tuple = nxfs-defs.target_tuple;
}
