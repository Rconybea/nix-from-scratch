{
  nxfsenv
} :

# FIXME: nxfsenv.mkDerivation fails to set PATH from buildInputs ?
#        or perhaps that's only if you replace the entire builder script
#
nxfsenv.mkDerivation {
  name = "binutils-stage1-wrapper";
  system = builtins.currentSystem;

  buildInputs = [ nxfsenv.coreutils nxfsenv.binutils nxfsenv.shell nxfsenv.gnused ];

  binutils = nxfsenv.binutils;
  glibc = nxfsenv.glibc;
  bash = nxfsenv.shell;

  builder = "${nxfsenv.shell}/bin/bash";
  args = [ ./builder.sh ];

  src = ./src;
}
