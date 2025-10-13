{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "2.72";

in

nxfsenv.mkDerivation {
  name         = "nxfs-autoconf-2";
  system       = builtins.currentSystem;
  inherit (nxfsenv) m4 perl coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gnused       = nxfsenv.gnused;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;
  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];
  src          = builtins.fetchTarball { name = "autoconf-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/autoconf/autoconf-${version}.tar.xz";
                                         sha256 = "1r3922ja9g5ziinpqxgfcc51jhrxvjqnrmc5054jgskylflxc1fp"; };
}
