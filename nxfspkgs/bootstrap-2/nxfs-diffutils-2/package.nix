# GOAL: incrementally migrate to look more like bootstrap-3/nxfs-diffutils-3/default.nix
#       (Don't expect to merge them, will still need different configure arguments)
#
# PLAN:
# 1. progressively replace direct imports with attributes of nxfsenv.
#    import ../../bootstrap-1/foo/default.nix -> nxfsenv.foo
# 2. provide+use nxfsenv.mkDerivation
# 3. use nix-only fetchurl instead of builtins.fetchTarball
{
  nxfsenv
} :

let
  version = "3.10";
in

nxfsenv.mkDerivation {
  name         = "nxfs-diffutils-2";

  system       = builtins.currentSystem;

  inherit (nxfsenv) coreutils gnumake gawk diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  sed          = nxfsenv.gnused;
  grep         = nxfsenv.gnugrep;
  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;


  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "diffutils-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz";
                                         sha256 = "13cxlscmjns6dk4yp0nmmyp1ldjkbag68lmgrizcd5dzz00xi8j7"; };
}
