let
  nxfs-gnumake-0         = import ../../bootstrap/nxfs-gnumake-0/default.nix;

  nxfs-tar-1             = import ../nxfs-tar-1/default.nix;
  nxfs-coreutils-1       = import ../nxfs-coreutils-1/default.nix;
  nxfs-patchelf-1        = import ../nxfs-patchelf-1/default.nix;
  nxfs-bash-1            = import ../nxfs-bash-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;
  nxfs-toolchain-1       = import ../nxfs-toolchain-1/default.nix;

  patchelf          = "${nxfs-patchelf-1}/bin/patchelf";
  bash              = "${nxfs-bash-1}/bin/bash";

  redirect_elf_file = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file.sh";
in

derivation {
  name               = "nxfs-gnumake-1";
  system             = builtins.currentSystem;

  nxfs_gnumake_0     = nxfs-gnumake-0;

  bash               = bash;
  builder            = bash;

  tar                = nxfs-tar-1;
  coreutils          = nxfs-coreutils-1;
  patchelf           = nxfs-patchelf-1;

  redirect_elf_file  = redirect_elf_file;

  nxfs_toolchain_1   = nxfs-toolchain-1;

  args               = [./builder.sh];

  buildInputs        = [];
}
