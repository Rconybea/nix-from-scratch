{
  # nxfsenv :: { mkDerivation :: attrs -> derivation,
  #              gcc-wrapper :: derivation,  (also as gcc_wrapper)
  #              binutils    :: derivation,
  #              gawk        :: derivation,
  #              gnumake     :: derivation,
  #              gnugrep     :: derivation,
  #              gnutar      :: derivation,
  #              gnused      :: derivation,
  #              findutils   :: derivation,
  #              coreutils   :: derivation,
  #              bash        :: derivation,
  #              glibc       :: derivation,
  #              nxfs-defs   :: { target_tuple :: string }
  #            }
  nxfsenv,
} :

let
  version = "3.10";
in

nxfsenv.mkDerivation {
  name         = "nxfs-diffutils-3";
  version      = version;

  src          = builtins.fetchTarball { name = "diffutils-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/diffutils/diffutils-${version}.tar.xz";
                                         sha256 = "13cxlscmjns6dk4yp0nmmyp1ldjkbag68lmgrizcd5dzz00xi8j7"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir
    mkdir -p $out

    # this might get us past the build.
    # Won't work for invoking `locate`, because location here will
    # be readonly downstream
    #
    mkdir -p $out/var/lib/locate

    bash_program=$bash/bin/bash

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src2/configure --prefix=$out --localstatedir=$out/var/lib/locate CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
    nxfsenv.gcc_wrapper
    nxfsenv.binutils
    nxfsenv.gawk
    nxfsenv.gnumake
    nxfsenv.gnugrep
    nxfsenv.gnutar
    nxfsenv.gnused
    nxfsenv.findutils
    nxfsenv.coreutils
    nxfsenv.bash
    nxfsenv.glibc
  ];
}
