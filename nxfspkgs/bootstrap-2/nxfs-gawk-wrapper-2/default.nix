let
  nxfs-sed-2          = import ../nxfs-sed-2/default.nix;
  nxfs-bash-2         = import ../nxfs-bash-2/default.nix;
  nxfs-gawk-2         = import ../nxfs-gawk-2/default.nix;
  nxfs-coreutils-2    = import ../nxfs-coreutils-2/default.nix;
  nxfs-execve-preload = import ../nxfs-execve-preload/default.nix;
in

derivation {
  name           = "gawk-wrapper-2";
  system         = builtins.currentSystem;

  sed            = nxfs-sed-2;
  bash           = nxfs-bash-2;
  gawk           = nxfs-gawk-2;
  coreutils      = nxfs-coreutils-2;
  execve_preload = nxfs-execve-preload;

  builder        = "${nxfs-bash-2}/bin/bash";
  args           = [ ./builder.sh ];

  src            = ./gawk-wrapper.sh;
}
