{
  # nxfsenv :: attrset
  nxfsenv,
} :

let
  version = "4.4.1";
in

nxfsenv.mkDerivation {
  name         = "nxfs-gnumake-3";

  src          = builtins.fetchTarball { name = "make-${version}-source";
                                         url = "https://ftpmirror.gnu.org/gnu/make/make-${version}.tar.gz";
                                         sha256 = "141z25axp7iz11sqci8c312zlmcmfy8bpyjpf0b0gfi8ri3kna7q";
                                       };

  buildPhase = ''
    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. substitute nix-store path-to-bash for /bin/sh.
    #
    #
    chmod -R +w $src2

    bash_program=$bash/bin/bash
    # Must skip:
    #   .m4 and .in files (assume they trigger re-running autoconf)
    #   test/ files
    #
    #sed -i -e "s:/bin/sh:$bash_program:g" $src2/configure #$src2/build-aux/*

    # 1. Replace
    #     const char *default_shell = "/bin/sh";
    #   with
    #     const char *default_shell = "$path/to/nix/store/$somehash/bin/bash";
    #
    #   Need this so that the gnu extension $(shell ..) works from within nix-build !
    #   Building bootstrap-2-demo/gnumake-1 verifies
    #
    (cd $src2 && sed -i -e 's:"/bin/sh":"'$bash_program'":' ./src/job.c)

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    (cd $builddir && $bash_program $src2/configure --prefix=$out --without-guile CFLAGS= LDFLAGS="-Wl,-enable-new-dtags")
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
  '';

  buildInputs = [ nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv.gnumake
                  nxfsenv.gawk
                  nxfsenv.gnutar
                  nxfsenv.gnugrep
                  nxfsenv.gnused
                  nxfsenv.findutils
                  nxfsenv.diffutils
                  nxfsenv.coreutils
                  nxfsenv.shell
                  nxfsenv.glibc
                ];
}
