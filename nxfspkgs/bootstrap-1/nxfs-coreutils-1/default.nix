let
  nxfs-coreutils-0 = import ../../bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-patchelf-0 = import ../../bootstrap/nxfs-patchelf-0/default.nix;
  nxfs-tar-0 = import ../../bootstrap/nxfs-tar-0/default.nix;
  nxfs-bash-1 = import ../nxfs-bash-1/default.nix;
  nxfs-sysroot-1 = import ../nxfs-sysroot-1/default.nix;

  bash = "${nxfs-bash-1}/bin/bash";
  basename = "${nxfs-coreutils-0}/bin/basename";
  chmod = "${nxfs-coreutils-0}/bin/chmod";
  head = "${nxfs-coreutils-0}/bin/head";
  mkdir = "${nxfs-coreutils-0}/bin/mkdir";
  patchelf = "${nxfs-patchelf-0}/bin/patchelf";
  tar = "${nxfs-tar-0}/bin/tar";
in

derivation {
  name = "nxfs-coreutils-1";
  system = builtins.currentSystem;

  bash = bash;
  chmod = chmod;
  basename = basename;
  head = head;
  mkdir = mkdir;
  builder = bash;
  patchelf = patchelf;
  tar = tar;

  nxfs_coreutils_0 = nxfs-coreutils-0;
  nxfs_sysroot_1 = nxfs-sysroot-1;

  args = [./builder.sh];

  buildInputs = [];
}
