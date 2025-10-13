{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  # note: version 1.17 available, but causes problems
  version = "1.16.5";

in

nxfsenv.mkDerivation {
  name         = "nxfs-automake-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) perl autoconf m4 coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gnused       = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "automake-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/automake/automake-${version}.tar.xz";
                                         sha256 = "0pac10hgw6r4kbafdbxg7gpb503fq9a9a31r5hvdh95nd2pcngv0"; };
}
