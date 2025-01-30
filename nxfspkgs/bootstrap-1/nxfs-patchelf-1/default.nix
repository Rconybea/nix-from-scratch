let
  nxfs-tar-0             = import ../../bootstrap/nxfs-tar-0/default.nix;
  nxfs-coreutils-0       = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-patchelf-0        = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-bash-1            = import            ../nxfs-bash-1/default.nix;
  nxfs-sysroot-1         = import         ../nxfs-sysroot-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash                   = "${nxfs-bash-1}/bin/bash";

  redirect_elf_file      = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file.sh";
in

derivation {
  name               = "nxfs-patchelf-1";
  system             = builtins.currentSystem;

  bash               = bash;
  builder            = bash;

  tar                = nxfs-tar-0;
  coreutils          = nxfs-coreutils-0;
  patchelf           = nxfs-patchelf-0;

  redirect_elf_file  = redirect_elf_file;
  nxfs_sysroot_1     = nxfs-sysroot-1;

  args               = [./builder.sh];

  target_interpreter = "${nxfs-sysroot-1}/lib64/ld-linux-x86-64.so.2";
  target_runpath     = "${nxfs-sysroot-1}/usr/lib:${nxfs-sysroot-1}/lib";

  buildInputs        = [ ../nxfs-redirect-elf-file ];
}
