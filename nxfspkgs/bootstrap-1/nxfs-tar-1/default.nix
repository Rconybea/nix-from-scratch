let
  nxfs-gnutar-0          = import ../../bootstrap/nxfs-tar-0/default.nix;

  nxfs-coreutils-1       = import ../nxfs-coreutils-1/default.nix;
  nxfs-patchelf-1        = import ../nxfs-patchelf-1/default.nix;
  nxfs-bash-1            = import ../nxfs-bash-1/default.nix;
  nxfs-toolchain-1       = import ../nxfs-toolchain-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash              = "${nxfs-bash-1}/bin/bash";

  redirect_elf_file_0 = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file-0.sh";
in

derivation {
  name                = "nxfs-tar-1";
  system              = builtins.currentSystem;

  bash                = bash;
  builder             = bash;

  gnutar              = nxfs-gnutar-0;
  coreutils           = nxfs-coreutils-1;
  patchelf            = nxfs-patchelf-1;
  redirect_elf_file_0 = redirect_elf_file_0;

  toolchain           = nxfs-toolchain-1;

  args                = [./builder.sh];

  buildInputs         = [];
}
