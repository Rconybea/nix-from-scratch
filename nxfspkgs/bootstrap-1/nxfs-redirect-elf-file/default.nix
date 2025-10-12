let
  nxfs-toolchain-0 = import ../../bootstrap/nxfs-toolchain-0/default.nix;
  nxfs-coreutils-0 = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-patchelf-0 = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-bash-0 = import ../../bootstrap/nxfs-bash-0/default.nix;
  nxfs-gnused-0 = import ../../bootstrap/nxfs-sed-0/default.nix;

  patchelf = "${nxfs-patchelf-0}/bin/patchelf";
  bash = "${nxfs-bash-0}/bin/bash";
  cp = "${nxfs-coreutils-0}/bin/cp";
  head = "${nxfs-coreutils-0}/bin/head";
  basename = "${nxfs-coreutils-0}/bin/basename";
  mkdir = "${nxfs-coreutils-0}/bin/mkdir";
  chmod = "${nxfs-coreutils-0}/bin/chmod";
  sed = "${nxfs-gnused-0}/bin/sed";
  ldso = "${nxfs-toolchain-0}/bin/ld.so";
in

derivation {
  name = "nxfs-redirect-elf-file";
  system = builtins.currentSystem;

  inherit bash patchelf cp mkdir head basename sed chmod;

  toolchain = nxfs-toolchain-0;
  builder = ldso;

  bash_builder = "./builder.sh";

  redirect_elf_file = ./redirect-elf-file.sh;
  redirect_elf_file_0 = ./redirect-elf-file-0.in;

  args = [
    "--library-path" "${nxfs-toolchain-0}/lib"
    bash
    ./builder.sh
  ];

  buildInputs = [];
}
