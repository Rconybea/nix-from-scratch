let
  nxfs-sed-1         = import ../../bootstrap-1/nxfs-sed-1/default.nix;

  nxfs-findutils-2   = import ../nxfs-findutils-2/default.nix;
  nxfs-diffutils-2   = import ../nxfs-diffutils-2/default.nix;
  nxfs-gcc-wrapper-2 = import ../nxfs-gcc-wrapper-2/default.nix;

  nxfs-gnumake-1     = import ../../bootstrap-1/nxfs-gnumake-1/default.nix;
  nxfs-gawk-1        = import ../../bootstrap-1/nxfs-gawk-1/default.nix;
  nxfs-tar-1         = import ../../bootstrap-1/nxfs-tar-1/default.nix;
  nxfs-grep-1        = import ../../bootstrap-1/nxfs-grep-1/default.nix;
  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;
  nxfs-coreutils-1   = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1        = import ../../bootstrap-1/nxfs-bash-1/default.nix;
in

derivation {
  name         = "nxfs-sed-2";
  system       = builtins.currentSystem;

  gnumake      = nxfs-gnumake-1;
  bash         = nxfs-bash-1;
  sed          = nxfs-sed-1;
  gcc_wrapper  = nxfs-gcc-wrapper-2;
  toolchain    = nxfs-toolchain-1;
  sysroot      = nxfs-sysroot-1;
  coreutils    = nxfs-coreutils-1;
  tar          = nxfs-tar-1;
  gnused       = nxfs-sed-1;
  gawk         = nxfs-gawk-1;
  grep         = nxfs-grep-1;
  findutils    = nxfs-findutils-2;
  diffutils    = nxfs-diffutils-2;

  builder      = "${nxfs-bash-1}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "sed-4.9-source";
                                         url = "https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz";
                                         sha256 = "170m9hyxnhnxisvmii5z7m8i446ab97kam10rqjylj70dk8wh169"; };

  target_tuple = "x86_64-pc-linux-gnu";
}
