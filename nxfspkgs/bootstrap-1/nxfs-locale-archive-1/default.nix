let
  nxfs-findutils-1 = import ../nxfs-findutils-1/default.nix;
  nxfs-gzip-1      = import      ../nxfs-gzip-1/default.nix;
  nxfs-tar-1       = import       ../nxfs-tar-1/default.nix;
  nxfs-coreutils-1 = import ../nxfs-coreutils-1/default.nix;
  nxfs-bash-1      = import      ../nxfs-bash-1/default.nix;
  nxfs-toolchain-1 = import ../nxfs-toolchain-1/default.nix;

  bash = "${nxfs-bash-1}/bin/bash";
in

derivation {
  name        = "nxfs-locale-archive-1";
  system      = builtins.currentSystem;

  findutils   = nxfs-findutils-1;
  gzip        = nxfs-gzip-1;
  tar         = nxfs-tar-1;
  coreutils   = nxfs-coreutils-1;
  bash        = nxfs-bash-1;
  toolchain   = nxfs-toolchain-1;

  builder     = bash;
  args        = [./builder.sh];

  nxfs_vars_file = ../../bootstrap/nxfs-vars.sh;

  buildInputs = [];
}
