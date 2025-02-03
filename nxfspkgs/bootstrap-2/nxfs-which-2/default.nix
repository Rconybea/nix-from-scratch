let
  nxfs-coreutils-2 = import ../nxfs-coreutils-2/default.nix;
  nxfs-bash-2 = import ../nxfs-bash-2/default.nix;
  nxfs-sed-2 = import ../nxfs-sed-2/default.nix;
in

derivation {
  name = "nxfs-which-2";
  system = builtins.currentSystem;

  coreutils = nxfs-coreutils-2;
  sed = nxfs-sed-2;
  bash = nxfs-bash-2;

  builder = "${nxfs-bash-2}/bin/bash";
  args    = [ ./builder.sh ];

  which_script = ./which.sh;
}
