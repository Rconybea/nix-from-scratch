{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version = "5.44";
in

nxfsenv.mkDerivation {
  name         = "nxfs-file-2";

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

  src          = builtins.fetchTarball { name = "file-${version}-source";
                                         url = "https://astron.com/pub/file/file-${version}.tar.gz";
                                         sha256 = "1zzm575fk4lsg8h0jk6jhcyk13w1qxm3ykssyqrmzq7wiginj9a3"; };
}
