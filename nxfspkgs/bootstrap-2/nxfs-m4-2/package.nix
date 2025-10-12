{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "1.4.19";

in

nxfsenv.mkDerivation {
  name         = "nxfs-m4-2";

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

  src          = builtins.fetchTarball { name = "m4-${version}-source";
                                         url = "https://mirror.csclub.uwaterloo.ca/gnu/m4/m4-${version}.tar.gz";
                                         sha256 = "02xz8gal0fdc4gzjwyiy1557q31xcpg896yc0y6kd8s5jbynvdmf"; };

  m4_patch    = ./m4-patch.sh;
}
