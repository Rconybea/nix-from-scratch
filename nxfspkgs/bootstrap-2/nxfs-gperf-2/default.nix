let

  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;
  nxfs-sed-2         = import ../nxfs-sed-2/default.nix;
  nxfs-grep-2        = import ../nxfs-grep-2/default.nix;
  nxfs-gawk-2        = import ../nxfs-gawk-2/default.nix;
  nxfs-gnumake-2     = import ../nxfs-gnumake-2/default.nix;
  nxfs-tar-2         = import ../nxfs-tar-2/default.nix;
  nxfs-bash-2        = import ../nxfs-bash-2/default.nix;
  nxfs-texinfo-2     = import ../nxfs-texinfo-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-coreutils-2   = import ../nxfs-coreutils-2/default.nix;
  nxfs-m4-2          = import ../nxfs-m4-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

in

derivation {
  name         = "nxfs-gperf-2";

  system       = builtins.currentSystem;

  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;

  texinfo      = nxfs-texinfo-2;
  m4           = nxfs-m4-2;
  diffutils    = nxfs-diffutils-2;
  findutils    = nxfs-findutils-2;
  coreutils    = nxfs-coreutils-2;
  bash         = nxfs-bash-2;
  tar          = nxfs-tar-2;
  gnumake      = nxfs-gnumake-2;
  gawk         = nxfs-gawk-2;
  sed          = nxfs-sed-2;
  grep         = nxfs-grep-2;
  gcc_wrapper  = nxfs-gcc-wrapper-2;

  builder      = "${nxfs-bash-2}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gperf-3.0.4-source";
                                         url = "https://ftp.gnu.org/gnu/gperf/gperf-3.0.4.tar.gz";
                                         sha256 = "12pqgvxmyckqv1b5qhi80qmwkvpvr604w7qckbn1dfkykl96rdgb"; };

  target_tuple ="x86_64-pc-linux-gnu";
}
