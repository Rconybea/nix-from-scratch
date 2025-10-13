{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "1.13";

in

nxfsenv.mkDerivation {
  name         = "nxfs-gzip-2";
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

  src          = builtins.fetchTarball { name = "gzip-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gzip/gzip-${version}.tar.xz";
                                         sha256 = "093w3a12220gzy00qi9zy52mhjlgyyh7kiimsz5xa00fgf81rbp9"; };
}
