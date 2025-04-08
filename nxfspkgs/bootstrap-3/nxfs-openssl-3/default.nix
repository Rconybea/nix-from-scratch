{
  # nxfsenv-3 :: derivation-set
  nxfsenv-3,
} :

let
  version = "3.3.1";
in

nxfsenv-3.mkDerivation {
  name         = "nxfs-openssl-3";

  src          = builtins.fetchTarball { name = "openssl-${version}-source";
                                         url = "https://www.openssl.org/source/openssl-${version}.tar.gz";
                                         sha256 = "1nclzfa6ivg7pj3nsfm2naypaxq33zk93bijpmmrdcdvdkb2r17r"; };

  zlib         = nxfsenv-3.zlib;

  buildPhase = ''
    src2=$TMPDIR/src2
    mkdir -p $src2

    builddir=$TMPDIR/build
    mkdir -p $builddir

    (cd $src && (tar cf - . | tar xf - -C $src2))
    chmod -R +w $src2

    perl_program=$(which perl)
    bash_program=$(which bash)

    sed -i -e "s:/bin/sh:$bash_program:" $src2/config
    sed -i -e "s:/usr/bin/env perl:$perl_program:" $src2/Configure

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    CFLAGS="-I$zlib/include"
    LDFLAGS="-Wl,-rpath,$out/lib -Wl,-enable-new-dtags"

    (cd $builddir && $perl_program $src2/config --prefix=$out CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" --openssldir=$out/etc/ssl --libdir=lib zlib-dynamic)
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

  '';

  buildInputs = [
    nxfsenv-3.gcc
    nxfsenv-3.perl
    nxfsenv-3.binutils
    nxfsenv-3.zlib
    nxfsenv-3.patch
    nxfsenv-3.gnumake
    nxfsenv-3.gawk
    nxfsenv-3.gnutar
    nxfsenv-3.gnugrep
    nxfsenv-3.gnused
    nxfsenv-3.findutils
    nxfsenv-3.diffutils
    nxfsenv-3.coreutils
    nxfsenv-3.bash
    nxfsenv-3.which
  ];
}
