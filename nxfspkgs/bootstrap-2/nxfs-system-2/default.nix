let
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-2 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-sed-2 = import ../nxfs-sed-2/default.nix;
in

derivation {
  name = "nxfs-system-2";
  system = builtins.currentSystem;

  coreutils = nxfs-coreutils-1;
  sed = nxfs-sed-2;
  bash = nxfs-bash-2;

  builder = "${nxfs-bash-2}/bin/bash";
  args = [./builder.sh];

  nxfs_system_src = ./nxfs_system.c;
  nxfs_popen_src = ./nxfs_popen.c;
}
