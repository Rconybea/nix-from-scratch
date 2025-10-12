{
  # nxfsenv : attrset
  nxfsenv
} :

let
  version = "1.3.1";

in

nxfsenv.mkDerivation {
  name         = "nxfs-zlib-2";

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

  src          = builtins.fetchTarball { name = "zlib-${version}-source";
                                         url = "https://zlib.net/fossils/zlib-${version}.tar.gz";
                                         sha256 = "1xx5zcp66gfjsxrads0gkfk6wxif64x3i1k0czmqcif8bk43rik9"; };
}
