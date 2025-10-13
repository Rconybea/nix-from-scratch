{
  # nxfsenv :: attrset
  nxfsenv,
  # locale-archive :: derivation
  locale-archive,
  # lc-all-sort :: derivation
  lc-all-sort
} :

let
  version = "2.40";
in

nxfsenv.mkDerivation {
  name         = "nxfs-glibc-x1-2";

  # reminder: for __noChroot to take effect, needs nix.conf to contain:
  #   sandbox = relaxed
  #
  #__noChroot = true;

  system       = builtins.currentSystem;

  locale_archive = locale-archive;
  lc_all_sort  = lc-all-sort;
  inherit (nxfsenv) patchelf python bison texinfo m4 patch gperf gzip binutils coreutils gnumake findutils diffutils;
  bash         = nxfsenv.shell;
  tar          = nxfsenv.gnutar;
  gawk         = nxfsenv.gawk;
  sed          = nxfsenv.gnused;
  grep         = nxfsenv.gnugrep;

  gcc_wrapper  = nxfsenv.toolchain;
  toolchain    = nxfsenv.toolchain.toolchain;

  patchfile    = ./glibc-2.40-fhs-1.patch;

  builder      = "${nxfsenv.shell}/bin/bash";
  args         = [ ./builder.sh ];

  src          = builtins.fetchTarball { name = "glibc-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/glibc/glibc-${version}.tar.xz";
                                         sha256 = "0ncvsz2r8py3z0v52fqniz5lq5jy30h0m0xx41ah19nl1rznflkh";
                                       };

  outputs      = [ "out" "source" ];
}
