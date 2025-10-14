{
  # expect this to be final env from bootstrap-2
  nxfsenv,
} :

let
  version = "4.10.0";
in

nxfsenv.mkDerivation {
  name         = "nxfs-findutils-3";
  version      = version;

  src          = builtins.fetchTarball { name = "findutils-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/findutils/findutils-${version}.tar.xz";
                                         sha256 = "17psmb481vpq03lmi8l4r4nm99v4yg3ri5bn4gyy0z1zzi63ywan"; };

  buildPhase = ''
    set -e

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # this might get us past the build.
    # Won't work for invoking `locate`, because location here will
    # be readonly downstream
    #
    mkdir -p $out/var/lib/locate

    bash_program=$bash/bin/bash

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. substitute nix-store path-to-bash for /bin/sh.
    #
    #
    chmod -R +w $src2
    sed -i "1s:#!.*/bin/sh:#!$bash_program:" $src2/build-aux/mkinstalldirs
    chmod -R -w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src2/configure --prefix=$out --localstatedir=$out/var/lib/locate CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")

    (cd $builddir && make SHELL=$CONFIG_SHELL)

    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [
    nxfsenv.diffutils
    nxfsenv.gcc_wrapper
    nxfsenv.binutils
    nxfsenv.gnumake
    nxfsenv.gawk
    nxfsenv.gnutar
    nxfsenv.gnugrep
    nxfsenv.gnused
    nxfsenv.coreutils
    nxfsenv.bash
    nxfsenv.glibc
  ];
}
