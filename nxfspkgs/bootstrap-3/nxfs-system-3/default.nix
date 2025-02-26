let
  nxfs-coreutils-2 = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-bash-3 = import ../../bootstrap-3/nxfs-bash-3/default.nix;
  nxfs-sed-3 = import ../nxfs-sed-3/default.nix;
in

derivation {
  name = "nxfs-system-3";
  system = builtins.currentSystem;

  coreutils = nxfs-coreutils-2;
  sed = nxfs-sed-3;
  bash = nxfs-bash-3;

  builder = "${nxfs-bash-3}/bin/bash";
  args = [./builder.sh];

  nxfs_system_src = ./nxfs_system.c;
}
