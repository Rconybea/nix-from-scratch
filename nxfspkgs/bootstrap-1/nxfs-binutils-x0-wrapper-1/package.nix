let
  nxfs-gnused-1 = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-defs = import ../nxfs-defs.nix;
in

# wrapper for bintools (ar, ld, ...) from nxfs-toolchain-1
#
derivation {
  name = "bintools-x0-wrapper-1";
  system = builtins.currentSystem;

  bash = nxfs-bash-1;
  binutils = nxfs-toolchain-1;
  coreutils = nxfs-coreutils-1;
  gnused = nxfs-gnused-1;
  glibc = nxfs-toolchain-1;

  builder = "${nxfs-bash-1}/bin/bash";
  args = [ ./builder.sh ];

  src = ./src;
  setup_hook = ./setup-hook.sh;

  target_tuple=nxfs-defs.target_tuple;
}
