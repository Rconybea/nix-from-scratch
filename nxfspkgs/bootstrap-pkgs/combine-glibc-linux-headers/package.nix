# Provide source tree that merges {linux, glibc} headers.
#
# Motivation is that when compiling gcc, build expects these
# in the same location.
#
# Alternatives to using this package (but with tradeoffs):
# - build gcc as cross compiler
# - do something with sysroot
# - skip gcc build's builtin bootstrap

{
  # nxfsenv :: attrset
  nxfsenv,
  # glibc :: derivation
  glibc,
  # linux-headers :: derivation
  linux-headers
} :

let
  version = "6.12.49";
  version_major = "6";
  tarball = "linux-${version}.tar.xz";
in

nxfsenv.mkDerivation {
  name = "combine-glibc-linux-headers";

  glibc = glibc;
  linux_headers = linux-headers;

  buildPhase = ''
    mkdir -p $out/include
    mkdir -p $out/include/scsi/fc

    cp -r $glibc/include/* $out/include
    cp -r $linux_headers/include/* $out/include

  '';
}
