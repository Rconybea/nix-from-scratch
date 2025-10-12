{
  nxfsenv
} :

let
  version = "4.9";
in

nxfsenv.mkDerivation {
  name         = "nxfs-sed-2";
  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk gnutar gnused findutils diffutils;
  bash         = nxfsenv.shell;
  grep         = nxfsenv.gnugrep;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "sed-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/sed/sed-${version}.tar.xz";
                                         sha256 = "170m9hyxnhnxisvmii5z7m8i446ab97kam10rqjylj70dk8wh169"; };
}
