{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "3.0.4";

in

nxfsenv.mkDerivation {
  name         = "nxfs-gperf-2";

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

  src          = builtins.fetchTarball { name = "gperf-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gperf/gperf-${version}.tar.gz";
                                         sha256 = "12pqgvxmyckqv1b5qhi80qmwkvpvr604w7qckbn1dfkykl96rdgb"; };
}
