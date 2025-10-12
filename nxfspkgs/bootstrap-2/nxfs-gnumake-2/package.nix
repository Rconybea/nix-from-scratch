{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "4.4.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-gnumake-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "make-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/make/make-${version}.tar.gz";
                                         sha256 = "141z25axp7iz11sqci8c312zlmcmfy8bpyjpf0b0gfi8ri3kna7q";
                                       };

}
