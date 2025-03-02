let
  nxfs-coreutils-2   = import ../../bootstrap-2/nxfs-coreutils-2/default.nix;
  nxfs-bash-2        = import ../../bootstrap-2/nxfs-bash-2/default.nix;
  nxfs-gawk-2        = import ../../bootstrap-2/nxfs-gawk-2/default.nix;
  nxfs-which-2       = import ../../bootstrap-2/nxfs-which-2/default.nix;
  nxfs-gcc-wrapper-2 = import ../../bootstrap-2/nxfs-gcc-wrapper-2/default.nix;

  nxfs-toolchain-1   = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-sysroot-1     = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  bash               = "${nxfs-bash-2}/bin/bash";

in

derivation {
  name = "gawk-1";
  system = builtins.currentSystem;

  gcc_wrapper = nxfs-gcc-wrapper-2;

  builder = "${nxfs-bash-2}/bin/bash";
  args = [ ./builder.sh ];

  which     = nxfs-which-2;
  bash      = nxfs-bash-2;
  gawk      = nxfs-gawk-2;
  coreutils = nxfs-coreutils-2;

  toolchain = nxfs-toolchain-1;
  sysroot = nxfs-sysroot-1;

  gawktestscript = ./gawktestscript;
}
