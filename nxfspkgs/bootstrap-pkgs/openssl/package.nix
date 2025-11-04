{
  # stdenv :: attrset+derivation
  stdenv,
  # perl :: derivation
  perl,
  # zlib :: derivation
  zlib,
  # stageid :: derivation
  stageid,
} :

let
  bash = stdenv.shell;
  version = "3.3.1";
in

stdenv.mkDerivation {
  name         = "nxfs-openssl-${stageid}";

  src          = builtins.fetchTarball { name = "openssl-${version}-source";
                                         url = "https://www.openssl.org/source/openssl-${version}.tar.gz";
                                         sha256 = "1nclzfa6ivg7pj3nsfm2naypaxq33zk93bijpmmrdcdvdkb2r17r"; };

  buildPhase = ''
    src2=$TMPDIR/src2
    mkdir -p $src2

    builddir=$TMPDIR/build
    mkdir -p $builddir

    echo "NIX_CFLAGS_COMPILE=$NIX_CFLAGS_COMPILE"
    echo "NIX_LDFLAGS=$NIX_LDFLAGS"

    (cd $src && (tar cf - . | tar xf - -C $src2))
    chmod -R +w $src2

    perl_program="${perl}/bin/perl"
    bash_program="${stdenv.shell}"

    sed -i -e "s:/bin/sh:$bash_program:" $src2/config
    sed -i -e "s:/usr/bin/env perl:$perl_program:" $src2/Configure

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    CFLAGS=$NIX_CFLAGS_COMPILE
    LDFLAGS="$NIX_LDFLAGS -Wl,-rpath,$out/lib -Wl,-enable-new-dtags"

    (cd $builddir && $perl_program $src2/config --prefix=$out CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" --openssldir=$out/etc/ssl --libdir=lib zlib-dynamic)
    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

  '';

  buildInputs = [ perl zlib ];
}
