let
  nxfs-toolchain-wrapper-1 = import ./nxfs-toolchain-wrapper-1;
  nxfs-binutils-x0-wrapper-1 = import ./nxfs-binutils-x0-wrapper-1/package.nix;
  nxfs-libxcrypt-1       = import ./nxfs-libxcrypt-1;
  nxfs-locale-archive-1  = import ./nxfs-locale-archive-1;
  nxfs-findutils-1       = import ./nxfs-findutils-1;
  nxfs-diffutils-1       = import ./nxfs-diffutils-1;
  nxfs-sed-1             = import ./nxfs-sed-1;
  nxfs-gnumake-1         = import ./nxfs-gnumake-1;
  nxfs-gawk-1            = import ./nxfs-gawk-1;
  nxfs-grep-1            = import ./nxfs-grep-1;
  nxfs-gzip-1            = import ./nxfs-gzip-1;
  nxfs-perl-1            = import ./nxfs-perl-1;
  nxfs-toolchain-1       = import ./nxfs-toolchain-1;
  nxfs-tar-1             = import ./nxfs-tar-1;
  nxfs-coreutils-1       = import ./nxfs-coreutils-1;
  nxfs-patchelf-1        = import ./nxfs-patchelf-1;
  nxfs-bash-1            = import ./nxfs-bash-1;
  nxfs-redirect-elf-file = import ./nxfs-redirect-elf-file;
  nxfs-sysroot-1         = import ./nxfs-sysroot-1;

  nxfs-bash-0            = import ../bootstrap/nxfs-bash-0;
  nxfs-sysroot-0         = import ../bootstrap/nxfs-sysroot-0;

  nxfs-empty-1           = import ./nxfs-empty-1/package.nix;
  nxfs-defs              = import ./nxfs-defs.nix;

  bash = "${nxfs-bash-0}/bin/bash";
in

derivation {
  name = "nxfs-stage-1";
  system = builtins.currentSystem;

  bash = bash;
  builder = "${nxfs-sysroot-0}/lib/ld-linux-x86-64.so.2";
  bash_builder = "./builder.sh";
  args = [bash ./builder.sh];

  buildInputs = [nxfs-toolchain-wrapper-1 nxfs-binutils-x0-wrapper-1
                 nxfs-libxcrypt-1 nxfs-perl-1
                 nxfs-findutils-1 nxfs-diffutils-1 nxfs-sed-1 nxfs-gnumake-1 nxfs-gawk-1 nxfs-gzip-1
                 nxfs-grep-1 nxfs-toolchain-1 nxfs-tar-1
                 nxfs-coreutils-1 nxfs-patchelf-1 nxfs-bash-1 nxfs-redirect-elf-file nxfs-sysroot-1
                ];

  nxfs-toolchain-wrapper-1 = nxfs-toolchain-wrapper-1;
  nxfs-binutils-x0-wrapper-1 = nxfs-binutils-x0-wrapper-1;
  nxfs-locale-archive-1  = nxfs-locale-archive-1;
  nxfs-perl-1            = nxfs-perl-1;
  nxfs-diffutils-1       = nxfs-diffutils-1;
  nxfs-findutils-1       = nxfs-findutils-1;
  nxfs-sed-1             = nxfs-sed-1;
  nxfs-gnumake-1         = nxfs-gnumake-1;
  nxfs-gawk-1            = nxfs-gawk-1;
  nxfs-grep-1            = nxfs-grep-1;
  nxfs-gzip-1            = nxfs-gzip-1;
  nxfs-toolchain-1       = nxfs-toolchain-1;
  nxfs-libxcrypt-1       = nxfs-libxcrypt-1;
  nxfs-tar-1             = nxfs-tar-1;
  nxfs-coreutils-1       = nxfs-coreutils-1;
  nxfs-patchelf-1        = nxfs-patchelf-1;
  nxfs-bash-1            = nxfs-bash-1;
  nxfs-redirect-elf-file = nxfs-redirect-elf-file;
  nxfs-sysroot-1         = nxfs-sysroot-1;
  nxfs-empty-1           = nxfs-empty-1;
  nxfs-defs-system       = nxfs-defs.system;
  nxfs-defs-target_tuple = nxfs-defs.target_tuple;
}
