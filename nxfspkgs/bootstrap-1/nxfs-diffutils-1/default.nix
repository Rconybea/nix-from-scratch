let
  nxfs-diffutils-0 = import ../../bootstrap/nxfs-diffutils-0/default.nix;
  nxfs-coreutils-1 = import ../nxfs-coreutils-1/default.nix;
  nxfs-patchelf-1 = import ../nxfs-patchelf-1/default.nix;
  nxfs-tar-1 = import ../../bootstrap-1/nxfs-tar-1/default.nix;
  nxfs-bash-1 = import ../nxfs-bash-1/default.nix;
  nxfs-sysroot-1 = import ../nxfs-sysroot-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash = "${nxfs-bash-1}/bin/bash";

  redirect_elf_file = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file.sh";
in

derivation {
  name = "nxfs-diffutils-1";
  system = builtins.currentSystem;
  builder = bash;

  coreutils = nxfs-coreutils-1;
  patchelf = nxfs-patchelf-1;
  tar = nxfs-tar-1;
  bash = nxfs-bash-1;

  nxfs_sysroot = nxfs-sysroot-1;
  redirect_elf_file = nxfs-redirect-elf-file;

  nxfs_diffutils_0 = nxfs-diffutils-0;

  args = [./builder.sh];

  target_interpreter = "${nxfs-sysroot-1}/lib64/ld-linux-x86-64.so.2";
  target_runpath = "${nxfs-sysroot-1}/usr/lib:${nxfs-sysroot-1}/lib";

  buildInputs = [];
}
