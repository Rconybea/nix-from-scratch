let
  nxfs-gnumake-2     = import ../../bootstrap-2/nxfs-gnumake-2/default.nix;
  nxfs-bash-2        = import ../../bootstrap-2/nxfs-bash-2/default.nix;
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  bash               = "${nxfs-bash-2}/bin/bash";

in

derivation {
  name = "gnumake-1";
  system = builtins.currentSystem;

  gcc_wrapper = nxfs-gcc-wrapper-2;
  bash = nxfs-bash-2;

  builder = "${nxfs-bash-2}/bin/bash";
  args = [ ./builder.sh ];

  gnumake = nxfs-gnumake-2;
  coreutils = nxfs-coreutils-2;

  toolchain = nxfs-toolchain-1;
  sysroot = nxfs-sysroot-1;

  mymakefile = ./mymakefile;
}
