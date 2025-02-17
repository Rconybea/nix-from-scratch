let
  nxfs-toolchain-1 = import ../../bootstrap-1/nxfs-toolchain-1/default.nix;
  nxfs-gawk-2 = import ../../bootstrap-2/nxfs-gawk-2/default.nix;
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-sed-1 = import ../../bootstrap-1/nxfs-sed-1/default.nix;
  nxfs-bash-1 = import ../../bootstrap-1/nxfs-bash-1/default.nix;
  nxfs-sysroot-1 = import ../../bootstrap-1/nxfs-sysroot-1/default.nix;

  mkdir = "${nxfs-coreutils-1}/bin/mkdir";
  bash = "${nxfs-bash-1}/bin/bash";

in

derivation {
  name = "awk-2";
  system = builtins.currentSystem;

  bash = bash;

  builder = bash;
  args = [ ./builder.sh ];

  toolchain = nxfs-toolchain-1;
  gawk = nxfs-gawk-2;
  sed = nxfs-sed-1;
  coreutils = nxfs-coreutils-1;
  sysroot = nxfs-sysroot-1;

  script = ./script.awk;
  input = ./input.txt;
}
