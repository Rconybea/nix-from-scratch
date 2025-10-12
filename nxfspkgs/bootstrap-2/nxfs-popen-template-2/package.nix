# minimal popen() / pclose() implementation;
# need for indirect build-time dependency
#   glibc-2 <- gawk-2 <- glibc-1
# popen()/pclose() from glibc-1 won't work during a sandbox build,
# because it restricts execution to programs in /usr/bin
#

{
  nxfsenv
} :

nxfsenv.mkDerivation {
  name = "nxfs-popen-template-2";
  system = builtins.currentSystem;

  inherit (nxfsenv) coreutils;
  bash = nxfsenv.shell;

  builder = "${nxfsenv.shell}/bin/bash";
  args = [./builder.sh];

  nxfs_system_src = ./nxfs_system.c;
  nxfs_popen_src = ./nxfs_popen.c;

  outputs = [ "out" ];
}
