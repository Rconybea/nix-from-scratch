let
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;

  nxfs-popen-template-2 = import ../nxfs-popen-template-2/default.nix;
  nxfs-bash-2 = import ../../bootstrap-2/nxfs-bash-2/default.nix;
  nxfs-sed-2 = import ../nxfs-sed-2/default.nix;
in

derivation {
  name = "nxfs-popen-2";
  system = builtins.currentSystem;

  coreutils = nxfs-coreutils-1;
  popen_template = nxfs-popen-template-2;
  sed = nxfs-sed-2;
  bash = nxfs-bash-2;

  builder = "${nxfs-bash-2}/bin/bash";
  args = [./builder.sh];
}
