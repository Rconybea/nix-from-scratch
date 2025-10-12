{
  # nxfsenv :: attrset
  nxfsenv
} :

let
  version-base = "5.0";
  version = "5.40.0";

in

nxfsenv.mkDerivation {
  name         = "nxfs-perl-2";

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

  src          = builtins.fetchTarball { name = "perl-${version}-source";
                                         sha256 = "1yiqddm0l774a87y13jmqm6w0j0dja7ycnigzkkbsy7gm5bkb8ig";
                                         url = "https://www.cpan.org/src/${version-base}/perl-${version}.tar.xz"; };
}
