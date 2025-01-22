let
  nxfs-mpc-2 = import ./nxfs-mpc-2/default.nix;
  nxfs-mpfr-2 = import ./nxfs-mpfr-2/default.nix;
  nxfs-gmp-2 = import ./nxfs-gmp-2/default.nix;
  nxfs-patch-2 = import ./nxfs-patch-2/default.nix;

  nxfs-bison-2 = import ./nxfs-bison-2/default.nix;
  nxfs-flex-2 = import ./nxfs-flex-2/default.nix;

  nxfs-texinfo-2 = import ./nxfs-texinfo-2/default.nix;
  nxfs-automake-2 = import ./nxfs-automake-2/default.nix;
  nxfs-autoconf-2 = import ./nxfs-autoconf-2/default.nix;
  nxfs-m4-2 = import ./nxfs-m4-2/default.nix;
  nxfs-perl-2 = import ./nxfs-perl-2/default.nix;

  nxfs-gperf-2 = import ./nxfs-gperf-2/default.nix;
  nxfs-zlib-2 = import ./nxfs-zlib-2/default.nix;
  nxfs-file-2 = import ./nxfs-file-2/default.nix;

  nxfs-coreutils-2 = import ./nxfs-coreutils-2/default.nix;
  nxfs-bash-2 = import ./nxfs-bash-2/default.nix;
  nxfs-tar-2 = import ./nxfs-tar-2/default.nix;
  nxfs-gnumake-2 = import ./nxfs-gnumake-2/default.nix;
  nxfs-gawk-2 = import ./nxfs-gawk-2/default.nix;
  nxfs-grep-2 = import ./nxfs-grep-2/default.nix;
  nxfs-sed-2 = import ./nxfs-sed-2/default.nix;
  nxfs-findutils-2 = import ./nxfs-findutils-2/default.nix;
  nxfs-diffutils-2 = import ./nxfs-diffutils-2/default.nix;
  nxfs-gcc-wrapper-2 = import ./nxfs-gcc-wrapper-2/default.nix;

  nxfs-bash-1 = import ../bootstrap-1/nxfs-bash-1/default.nix;

  bash = "${nxfs-bash-1}/bin/bash";
in

derivation {
  name = "nxfs-stage-2";
  system = builtins.currentSystem;

  builder = bash;

  nxfs-mpc-2 = nxfs-mpc-2;
  nxfs-mpfr-2 = nxfs-mpfr-2;
  nxfs-gmp-2 = nxfs-gmp-2;
  nxfs-patch-2 = nxfs-patch-2;

  nxfs-bison-2 = nxfs-bison-2;
  nxfs-flex-2 = nxfs-flex-2;

  nxfs-texinfo-2 = nxfs-texinfo-2;
  nxfs-automake-2 = nxfs-automake-2;
  nxfs-autoconf-2 = nxfs-autoconf-2;
  nxfs-m4-2 = nxfs-m4-2;
  nxfs-perl-2 = nxfs-perl-2;

  nxfs-gperf-2 = nxfs-gperf-2;
  nxfs-zlib-2 = nxfs-zlib-2;
  nxfs-file-2 = nxfs-file-2;

  nxfs-coreutils-2 = nxfs-coreutils-2;
  nxfs-bash-2 = nxfs-bash-2;
  nxfs-tar-2 = nxfs-tar-2;
  nxfs-gnumake-2 = nxfs-gnumake-2;
  nxfs-gawk-2 = nxfs-gawk-2;
  nxfs-grep-2 = nxfs-grep-2;
  nxfs-sed-2 = nxfs-sed-2;
  nxfs-findutils-2 = nxfs-findutils-2;
  nxfs-diffutils-2 = nxfs-diffutils-2;
  nxfs-gcc-wrapper-2 = nxfs-gcc-wrapper-2;
}
