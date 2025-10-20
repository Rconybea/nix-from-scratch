{
  # stdenv: derivation+attrset.
  stdenv,
  # stageid :: string  -- bootstrap stage of this package. "2" for stage 2, "3" for stage 3
  stageid,
} :

let
  version = "3.10";
in

stdenv.mkDerivation {
  name         = "nxfs-diffutils-${stageid}";
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

    shell_program=$shell

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$shell_program"

    (cd $builddir && $shell_program $src2/configure --prefix=$out --localstatedir=$out/var/lib/locate CC=nxfs-gcc CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [];
}
