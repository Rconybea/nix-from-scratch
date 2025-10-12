let
  nxfs-gnugrep-1           = import ../../bootstrap-1/nxfs-grep-1/default.nix;

  nxfs-toolchain-wrapper-1 = import ../../bootstrap-1/nxfs-toolchain-wrapper-1/default.nix;

  nxfs-gnumake-1           = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-gawk-1              = import ../../bootstrap-1/nxfs-gawk-1/default.nix;
  nxfs-gnutar-1            = import ../../bootstrap-1/nxfs-tar-1/default.nix;
  nxfs-toolchain-1         = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1         = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1              = import ../../bootstrap-1/nxfs-bash-1/default.nix;

  nxfs-gnused-2            = import ../nxfs-sed-2/default.nix;
  nxfs-findutils-2         = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2         = import ../nxfs-diffutils-2/default.nix;

  nxfs-defs                = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-grep-2";
  system       = builtins.currentSystem;

  gnumake      = nxfs-gnumake-1;
  bash         = nxfs-bash-1;
  toolchain    = nxfs-toolchain-1;
  coreutils    = nxfs-coreutils-1;
  gnutar       = nxfs-gnutar-1;
  gawk         = nxfs-gawk-1;
  gnugrep      = nxfs-gnugrep-1;

  gnused       = nxfs-gnused-2;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;

  gcc_wrapper  = nxfs-toolchain-wrapper-1;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "grep-3.11-source";
                                         url = "https://ftpmirror.gnu.org/gnu/grep/grep-3.11.tar.xz";
                                         sha256 = "0pm0zpzmmy6lq5ii03y1nqr1sdjalnwp69i5c926c9dm03v7v0bv"; };
}
