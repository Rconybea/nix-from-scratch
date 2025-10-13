{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "2.6.4";

in

nxfsenv.mkDerivation {
  name         = "nxfs-flex-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) m4 file coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "flex-${version}-source";
                                         url = "https://github.com/westes/flex/releases/download/v${version}/flex-${version}.tar.gz";
                                         sha256 = "05gbq5hklzdfvjjc3hyr98hrm8wkr20ds0y3l7c825va798c04qw"; };
}
