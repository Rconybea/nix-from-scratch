let
  nxfs-sysroot-0 = import ../../bootstrap/nxfs-sysroot-0/default.nix;
  nxfs-sysroot-1 = import ../nxfs-sysroot-1/default.nix;
  nxfs-coreutils-0 = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-patchelf-0 = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-tar-0 = import ../../bootstrap/nxfs-tar-0/default.nix;
  nxfs-bash-0 = import ../../bootstrap/nxfs-bash-0/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash = "${nxfs-bash-0}/bin/bash";
  builder = "${nxfs-sysroot-0}/lib/ld-linux-x86-64.so.2";
  redirect_elf_file = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file.sh";
in

derivation {
  name = "nxfs-bash-1";
  system = builtins.currentSystem;

  bash = bash;
  builder = builder;

  tar = nxfs-tar-0;
  patchelf = nxfs-patchelf-0;
  coreutils = nxfs-coreutils-0;

  redirect_elf_file = redirect_elf_file;

  nxfs_sysroot_1 = nxfs-sysroot-1;
  nxfs_bash_0 = nxfs-bash-0;

  bash_builder = "./builder.sh";

  args = [bash ./builder.sh];

  target_interpreter = "${nxfs-sysroot-1}/lib64/ld-linux-x86-64.so.2";
  target_runpath = "${nxfs-sysroot-1}/usr/lib:${nxfs-sysroot-1}/lib";

  buildInputs = [];
}
