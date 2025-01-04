{
  pills-example-1  = import ./nix-pills/example1/default.nix;

  nxfs-zlib        = import ./bootstrap/nxfs-zlib-1/default.nix;

  nxfs-bash-0      = import ./bootstrap/nxfs-bash-0/default.nix;
  nxfs-coreutils-0 = import ./bootstrap/nxfs-coreutils-0/default.nix;
  nxfs-gnumake-0   = import ./bootstrap/nxfs-gnumake-0/default.nix;
  # not sure if we need this in bootstrap
  nxfs-m4-0        = import ./bootstrap/nxfs-m4-0/default.nix;

  nxfs-toolchain-0 = import ./bootstrap/nxfs-toolchain-0/default.nix;
  nxfs-sysroot-0   = import ./bootstrap/nxfs-sysroot-0/default.nix;

  nxfs-bootstrap-1 = import ./bootstrap-1/default.nix;
}
