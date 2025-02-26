let
  nxfs-grep-2        = import ../../bootstrap-2/nxfs-grep-2/default.nix;

  nxfs-sed-3         = import ../../bootstrap-3/nxfs-sed-3/default.nix;
  nxfs-findutils-3   = import ../../bootstrap-3/nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../../bootstrap-3/nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;
  nxfs-binutils-2    = import ../../bootstrap-2/nxfs-binutils-2/default.nix;
  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;

  nxfs-gnumake-2     = import ../../bootstrap-2/nxfs-gnumake-2/default.nix;
  nxfs-gawk-2        = import ../../bootstrap-2/nxfs-gawk-2/default.nix;
  nxfs-tar-2         = import ../../bootstrap-2/nxfs-tar-2/default.nix;
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-bash-2        = import ../../bootstrap-2/nxfs-bash-2/default.nix;
  nxfs-defs          = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-grep-3";
  system       = builtins.currentSystem;

  gnumake      = nxfs-gnumake-2;
  bash         = nxfs-bash-2;
  coreutils    = nxfs-coreutils-2;
  tar          = nxfs-tar-2;
  gawk         = nxfs-gawk-2;
  grep         = nxfs-grep-2;

  sed          = nxfs-sed-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  binutils     = nxfs-binutils-2;
  glibc        = nxfs-glibc-stage1-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "grep-3.11-source";
                                         url = "https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz";
                                         sha256 = "0pm0zpzmmy6lq5ii03y1nqr1sdjalnwp69i5c926c9dm03v7v0bv"; };

  target_tuple = nxfs-defs.target_tuple;
}
