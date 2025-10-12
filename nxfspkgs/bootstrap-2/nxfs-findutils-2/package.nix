{
  nxfsenv
} :

let
  version = "4.10.0";
in

nxfsenv.mkDerivation {
  name         = "nxfs-findutils-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  sed          = nxfsenv.gnused;
  grep         = nxfsenv.gnugrep;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "findutils-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/findutils/findutils-${version}.tar.xz";
                                         sha256 = "17psmb481vpq03lmi8l4r4nm99v4yg3ri5bn4gyy0z1zzi63ywan"; };
}
