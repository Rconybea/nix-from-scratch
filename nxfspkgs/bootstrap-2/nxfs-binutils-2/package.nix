{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "2.43.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-binutils-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) perl m4 coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "binutils-${version}-source";
                                         url = "https://sourceware.org/pub/binutils/releases/binutils-${version}.tar.xz";
                                         sha256 = "1z0lq9ia19rw1qk09i3im495s5zll7xivdslabydxl9zlp3wy570"; };
}
