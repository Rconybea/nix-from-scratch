{
  # nxfsenv :: attrset
  nxfsenv,
  # popen :: derivation
  popen
} :

let
  version = "3.12.6";

in

nxfsenv.mkDerivation {
  name         = "nxfs-python-2";
  system       = builtins.currentSystem;

  inherit popen;
  inherit (nxfsenv) zlib coreutils gnumake gawk findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gnused       = nxfsenv.gnused;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "python-${version}-source";
                                         url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
                                         sha256 = "0ggdm1l4dhr3qn0rwzjha5r15m3mfyl0hj8j89xip7jx10mip952"; };

  # nix-build -A source
  outputs = [ "out" "source" ];
}
