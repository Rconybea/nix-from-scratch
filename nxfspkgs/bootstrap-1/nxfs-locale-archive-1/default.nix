let
  nxfs-gzip-1      = import      ../nxfs-gzip-1/default.nix;
  nxfs-tar-1       = import       ../nxfs-tar-1/default.nix;
  nxfs-coreutils-1 = import ../nxfs-coreutils-1/default.nix;
  nxfs-bash-1      = import      ../nxfs-bash-1/default.nix;
  nxfs-sysroot-1   = import   ../nxfs-sysroot-1/default.nix;

  bash = "${nxfs-bash-1}/bin/bash";
in

derivation {
  name        = "nxfs-locale-archive-1";
  system      = builtins.currentSystem;

  gzip        = nxfs-gzip-1;
  tar         = nxfs-tar-1;
  coreutils   = nxfs-coreutils-1;
  bash        = nxfs-bash-1;
  sysroot     = nxfs-sysroot-1;

  builder     = bash;
  args        = [./builder.sh];

  buildInputs = [];
}
