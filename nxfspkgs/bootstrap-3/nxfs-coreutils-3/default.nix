let
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;

  nxfs-sed-3         = import ../nxfs-sed-3/default.nix;
  nxfs-grep-3        = import ../nxfs-grep-3/default.nix;
  nxfs-gawk-3        = import ../nxfs-gawk-3/default.nix;
  nxfs-gnumake-3     = import ../nxfs-gnumake-3/default.nix;
  nxfs-tar-3         = import ../nxfs-tar-3/default.nix;
  nxfs-bash-3        = import ../nxfs-bash-3/default.nix;
  nxfs-findutils-3   = import ../nxfs-findutils-3/default.nix;
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;
  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;
  nxfs-binutils-2 = import ../../bootstrap-2/nxfs-binutils-2/default.nix;

  nxfs-defs = import ../nxfs-defs.nix;
in

derivation {
  name         = "nxfs-coreutils-3";

  system       = builtins.currentSystem;

  coreutils    = nxfs-coreutils-2;

  bash         = nxfs-bash-3;
  tar          = nxfs-tar-3;
  gnumake      = nxfs-gnumake-3;
  gawk         = nxfs-gawk-3;
  sed          = nxfs-sed-3;
  grep         = nxfs-grep-3;
  findutils    = nxfs-findutils-3;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-3}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "coreutils-9.5-source";
                                         url = "https://ftp.gnu.org/gnu/coreutils/coreutils-9.5.tar.xz";
                                         sha256 = "0250l3qc7w4l2lx2ws4wqsd2g2g2q0g6w32d9r7d9pgwqmrj2nkh"; };

  target_tuple = nxfs-defs.target_tuple;
}
