let
  nxfs-toolchain-0       = import ../../bootstrap/nxfs-toolchain-0/default.nix;

  nxfs-coreutils-1       = import ../nxfs-coreutils-1/default.nix;
  nxfs-patchelf-1        = import ../nxfs-patchelf-1/default.nix;
  nxfs-tar-1             = import ../nxfs-tar-1/default.nix;
  nxfs-bash-1            = import ../nxfs-bash-1/default.nix;
  nxfs-sysroot-1         = import ../nxfs-sysroot-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash              = "${nxfs-bash-1}/bin/bash";
  basename          = "${nxfs-coreutils-1}/bin/basename";
  chmod             = "${nxfs-coreutils-1}/bin/chmod";
  head              = "${nxfs-coreutils-1}/bin/head";
  mkdir             = "${nxfs-coreutils-1}/bin/mkdir";
  patchelf          = "${nxfs-patchelf-1}/bin/patchelf";
  tar               = "${nxfs-tar-1}/bin/tar";

  redirect_elf_file = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file.sh";
in

derivation {
  name               = "nxfs-toolchain-1";
  system             = builtins.currentSystem;

  bash               = bash;
  chmod              = chmod;
  basename           = basename;
  head               = head;
  mkdir              = mkdir;
  builder            = bash;
  patchelf           = patchelf;
  tar                = tar;

  redirect_elf_file  = redirect_elf_file;

  nxfs_toolchain_0   = nxfs-toolchain-0;

  args               = [./builder.sh];

  target_interpreter = "${nxfs-sysroot-1}/lib64/ld-linux-x86-64.so.2";
  target_runpath     = "${nxfs-sysroot-1}/usr/lib:${nxfs-sysroot-1}/lib";

  buildInputs        = [];
}
