let
  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;

  nxfs-diffutils-1   = import ../../bootstrap-1/nxfs-diffutils-1/default.nix;
  nxfs-sed-1         = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-grep-1        = import ../../bootstrap-1/nxfs-grep-1/default.nix;
  nxfs-gawk-1        = import ../../bootstrap-1/nxfs-gawk-1/default.nix;
  nxfs-gnumake-1     = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-tar-1         = import ../../bootstrap-1/nxfs-tar-1/default.nix;
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-diffutils-2";

  system       = builtins.currentSystem;

  toolchain    = nxfs-toolchain-1;

  diffutils    = nxfs-diffutils-1;
  coreutils    = nxfs-coreutils-1;
  bash         = nxfs-bash-1;
  tar          = nxfs-tar-1;
  gnumake      = nxfs-gnumake-1;
  gawk         = nxfs-gawk-1;
  sed          = nxfs-sed-1;
  grep         = nxfs-grep-1;
  gcc_wrapper  = nxfs-toolchain-wrapper-1;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "diffutils-3.10-source";
                                         url = "https://ftpmirror.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz";
                                         sha256 = "13cxlscmjns6dk4yp0nmmyp1ldjkbag68lmgrizcd5dzz00xi8j7"; };
}
