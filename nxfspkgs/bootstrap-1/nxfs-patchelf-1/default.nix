# BOOTSTRAP REMARKS:
# At this point in bootstrap, we have
# - patched toolchain nxfs-toolchain-1
# - patched bash nxfs-bash-1
# This means we can drop the linker crutch to invoke builder.sh;
# will still need it for coreutils (mkdir, chmod, readlink, ...)

let
  nxfs-gnutar-0          = import ../../bootstrap/nxfs-tar-0/default.nix;
  nxfs-coreutils-0       = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-patchelf-0        = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-bash-1            = import ../nxfs-bash-1/default.nix;
  nxfs-toolchain-1       = import ../nxfs-toolchain-1/default.nix;
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;

  bash                   = "${nxfs-bash-1}/bin/bash";

  redirect_elf_file_0    = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file-0.sh";
in

derivation {
  name                = "nxfs-patchelf-1";
  system              = builtins.currentSystem;

  bash                = bash;
  builder             = bash;

  gnutar              = nxfs-gnutar-0;
  coreutils           = nxfs-coreutils-0;
  patchelf            = nxfs-patchelf-0;

  redirect_elf_file_0 = redirect_elf_file_0;
  nxfs_toolchain_1    = nxfs-toolchain-1;

  args                = [./builder.sh];

  buildInputs         = [ ../nxfs-redirect-elf-file ];
}
