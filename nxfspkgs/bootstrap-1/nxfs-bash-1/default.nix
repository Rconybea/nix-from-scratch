let
  nxfs-redirect-elf-file = import ../nxfs-redirect-elf-file/default.nix;
  nxfs-toolchain-1 = import ../nxfs-toolchain-1/default.nix;
  nxfs-coreutils-0 = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-patchelf-0 = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-gnutar-0 = import ../../bootstrap/nxfs-tar-0/default.nix;

  # source: will be copying patched version of nxfs-bash-0 -> ${out}
  nxfs-bash-0 = import ../../bootstrap/nxfs-bash-0/default.nix;

  bash = "${nxfs-bash-0}/bin/bash";
  builder = "${nxfs-toolchain-1}/bin/ld.so";

  redirect_elf_file_0 = "${nxfs-redirect-elf-file}/bootstrap-scripts/redirect-elf-file-0.sh";
in

derivation {
  name = "nxfs-bash-1";
  system = builtins.currentSystem;

  bash = bash;
  builder = builder;

  gnutar = nxfs-gnutar-0;
  patchelf = nxfs-patchelf-0;
  coreutils = nxfs-coreutils-0;

  redirect_elf_file_0 = redirect_elf_file_0;

  nxfs_toolchain_1 = nxfs-toolchain-1;
  nxfs_bash_0 = nxfs-bash-0;

  bash_builder = "./builder.sh";

  args = [
    "--library-path" "${nxfs-toolchain-1}/lib"
    bash
    ./builder.sh
  ];

  buildInputs = [];
}
