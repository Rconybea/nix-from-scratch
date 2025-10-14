{
  nxfsenv,

  # popen :: derivation
  popen
} :

let
  version = "5.3.0";
in

derivation {
  name         = "nxfs-gawk-2";
  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk findutils diffutils;
  # popen: source code for nxfs_system() = nix-centric re-implementation of system(),popen()
  popen        = popen;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  grep         = nxfsenv.gnugrep;
  sed          = nxfsenv.gnused;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "gawk-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/gawk/gawk-${version}.tar.xz";
                                         sha256 = "03fsh86d3jbafmbhm1n0rx8wzsbvlfmpdscfx85dqx6isyk35sd9"; };

  # nix-build -A source
  outputs      = [ "out" "source" ];
}
