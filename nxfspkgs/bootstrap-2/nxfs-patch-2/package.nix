{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "2.7.6";

in

nxfsenv.mkDerivation {
  name         = "nxfs-patch-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gnused       = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "patch-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/patch/patch-${version}.tar.xz";
                                         sha256 = "1yiy0xq1ha193yga0canc9ijw4hbd92c93l7ksqlhmzsn2yph39n"; };
}
