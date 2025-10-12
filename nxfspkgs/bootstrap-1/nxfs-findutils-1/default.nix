let
  nxfs-findutils-0 = import ../../bootstrap/nxfs-findutils-0/default.nix;
  nxfs-coreutils-1 = import ../nxfs-coreutils-1/default.nix;
  nxfs-patchelf-1 = import ../nxfs-patchelf-1/default.nix;
  nxfs-tar-1 = import ../../bootstrap-1/nxfs-tar-1/default.nix;
  nxfs-bash-1 = import ../nxfs-bash-1/default.nix;
  nxfs-toolchain-1 = import ../nxfs-toolchain-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash = "${nxfs-bash-1}/bin/bash";

  redirect_elf_file = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file.sh";
in

derivation {
  name = "nxfs-findutils-1";
  system = builtins.currentSystem;
  builder = bash;

  coreutils = nxfs-coreutils-1;
  patchelf = nxfs-patchelf-1;
  tar = nxfs-tar-1;
  bash = nxfs-bash-1;

  toolchain = nxfs-toolchain-1;
  redirect_elf_file = nxfs-redirect-elf-file;

  nxfs_findutils_0 = nxfs-findutils-0;

  args = [./builder.sh];

  buildInputs = [];
}
