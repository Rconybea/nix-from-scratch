let
  nxfs-diffutils-3   = import ../nxfs-diffutils-3/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;
  nxfs-glibc-stage1-2 = import ../../bootstrap-2/nxfs-glibc-stage1-2/default.nix;

  nxfs-sed-2         = import ../../bootstrap-2/nxfs-sed-2/default.nix;
  nxfs-grep-2        = import ../../bootstrap-2/nxfs-grep-2/default.nix;
  nxfs-gawk-2        = import ../../bootstrap-2/nxfs-gawk-2/default.nix;
  nxfs-gnumake-2     = import ../../bootstrap-2/nxfs-gnumake-2/default.nix;
  nxfs-tar-2         = import ../../bootstrap-2/nxfs-tar-2/default.nix;
  nxfs-bash-2        = import ../../bootstrap-2/nxfs-bash-2/default.nix;
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-binutils-2     = import ../../bootstrap-2/nxfs-binutils-2/default.nix;
  nxfs-defs          = import ../nxfs-defs.nix;
in


derivation {
  name         = "nxfs-findutils-3";

  system       = builtins.currentSystem;

  coreutils    = nxfs-coreutils-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  sed          = nxfs-sed-2;
  grep         = nxfs-grep-2;
  diffutils    = nxfs-diffutils-3;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  binutils     = nxfs-binutils-2;
  glibc        = nxfs-glibc-stage1-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "findutils-4.10.0-source";
                                         url = "https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz";
                                         sha256 = "17psmb481vpq03lmi8l4r4nm99v4yg3ri5bn4gyy0z1zzi63ywan"; };

  target_tuple = nxfs-defs.target_tuple;
}
