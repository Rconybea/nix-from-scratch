let
  nxfs-bash-1 = import ../nxfs-bash-1/default.nix;
  nxfs-coreutils-1 = import ../nxfs-coreutils-1/default.nix;

  shell = "${nxfs-bash-1}/bin/bash";
in

derivation {
  name = "nxfs-empty-1";
  system = builtins.currentSystem;

  shell = shell;
  builder = shell;

  coreutils = nxfs-coreutils-1;

  args = [ ./builder.sh ];

}
