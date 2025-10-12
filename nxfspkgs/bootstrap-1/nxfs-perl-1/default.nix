let
  nxfs-perl-0            = import ../../bootstrap/nxfs-perl-0/default.nix;

  nxfs-libxcrypt-1       = import ../nxfs-libxcrypt-1/default.nix;

  nxfs-tar-1             = import ../nxfs-tar-1/default.nix;
  nxfs-coreutils-1       = import ../nxfs-coreutils-1/default.nix;
  nxfs-patchelf-1        = import ../nxfs-patchelf-1/default.nix;
  nxfs-bash-1            = import ../nxfs-bash-1/default.nix;
  nxfs-toolchain-1       = import ../nxfs-toolchain-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

#  gnumake           = "${nxfs-gnumake-1}/bin/make";
  tar               = "${nxfs-tar-1}/bin/tar";
  bash              = "${nxfs-bash-1}/bin/bash";
  basename          = "${nxfs-coreutils-1}/bin/basename";
  head              = "${nxfs-coreutils-1}/bin/head";
  chmod             = "${nxfs-coreutils-1}/bin/chmod";
  mkdir             = "${nxfs-coreutils-1}/bin/mkdir";
  patchelf          = "${nxfs-patchelf-1}/bin/patchelf";

  redirect_elf_file = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file.sh";
in

derivation {
  name               = "nxfs-perl-1";
  system             = builtins.currentSystem;

  basename           = basename;
  head               = head;
  bash               = bash;
  chmod              = chmod;
  mkdir              = mkdir;
  builder            = bash;
  patchelf           = patchelf;
  tar                = tar;

  redirect_elf_file  = redirect_elf_file;

  nxfs_perl_0        = nxfs-perl-0;
  nxfs_libxcrypt_1   = nxfs-libxcrypt-1;
  nxfs_toolchain_1   = nxfs-toolchain-1;

  args               = [./builder.sh];

  target_interpreter = "${nxfs-toolchain-1}/lib64/ld-linux-x86-64.so.2";
  target_runpath     = "${nxfs-libxcrypt-1}/lib:${nxfs-toolchain-1}/lib";

  buildInputs        = [];
}
