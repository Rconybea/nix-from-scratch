# minimal popen() / pclose() implementation;
# need for indirect build-time dependency
#   glibc-2 <- gawk-2 <- glibc-1
# popen()/pclose() from glibc-1 won't work during a sandbox build,
# because it restricts execution to programs in /usr/bin
#

let
  nxfs-coreutils-1 = import ../../bootstrap-1/nxfs-coreutils-1/default.nix;
  nxfs-bash-2 = import ../../bootstrap-2/nxfs-bash-2/default.nix;
in

derivation {
  name = "nxfs-popen-template-2";
  system = builtins.currentSystem;

  coreutils = nxfs-coreutils-1;
  bash = nxfs-bash-2;

  builder = "${nxfs-bash-2}/bin/bash";
  args = [./builder.sh];

  nxfs_system_src = ./nxfs_system.c;
  nxfs_popen_src = ./nxfs_popen.c;

  outputs = [ "out" ];
}
