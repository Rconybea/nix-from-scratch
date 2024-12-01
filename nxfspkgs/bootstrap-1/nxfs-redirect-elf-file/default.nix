let
  nxfs-sysroot-0 = import ../../bootstrap/nxfs-sysroot-0/default.nix;
  nxfs-sysroot-1 = import ../nxfs-sysroot-1/default.nix;
  nxfs-coreutils-0 = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-patchelf-0 = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-tar-0 = import ../../bootstrap/nxfs-tar-0/default.nix;
  nxfs-bash-0 = import ../../bootstrap/nxfs-bash-0/default.nix;

  bash = "${nxfs-bash-0}/bin/bash";
  chmod = "${nxfs-coreutils-0}/bin/chmod";
  cp = "${nxfs-coreutils-0}/bin/cp";
  mkdir = "${nxfs-coreutils-0}/bin/mkdir";
  patchelf = "${nxfs-patchelf-0}/bin/patchelf";
  tar = "${nxfs-tar-0}/bin/tar";
  ld-linux = "${nxfs-sysroot-0}/lib/ld-linux-x86-64.so.2";
in

derivation {
  name = "nxfs-redirect-elf-file";
  system = builtins.currentSystem;

  bash = bash;
  chmod = chmod;
  cp = cp;
  mkdir = mkdir;
  builder = ld-linux;
  patchelf = patchelf;
  tar = tar;

  nxfs_sysroot_1 = nxfs-sysroot-1;
  nxfs_bash_0 = nxfs-bash-0;

  bash_builder = "./builder.sh";

  redirect_elf_file = ./redirect-elf-file.sh;

  args = [bash ./builder.sh];

  buildInputs = [];
}
