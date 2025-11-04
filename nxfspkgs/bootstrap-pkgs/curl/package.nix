{
  # stdenv :: derivation+attrset
  stdenv,
  # perl :: derivation
  perl,
  # openssl :: derivation
  openssl,
  # stageid :: string
  stageid,
} :

let
  version = "8.9.1";

  fig_sigpipe_leak_patch = ./fix-sigpipe-leak.patch;
in

stdenv.mkDerivation {
  name         = "nxfs-curl-${stageid}";

  src          = builtins.fetchTarball { name = "curl-${version}-source";
                                         url = "https://curl.haxx.se/download/curl-${version}.tar.gz";
                                         sha256 = "08n6czcz6jmlcx89dabbjpg7xjpyabrda2fxrz842qqxgg818ga8"; };

  fix_sigpipe_leak_patch = ./fix-sigpipe-leak.patch;

  buildPhase = ''
    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    (cd $src && (tar cf - . | tar xf - -C $src2))
    chmod -R +w $src2

    # see https://curl.haxx.se/mail/tracker-2014-03/0087.html
    rm -f $src2/src/tool_hugehelp.c
    (cd $src2 && patch -p1 < $fix_sigpipe_leak_patch)

    perl_program="${perl}/bin/perl"  #$(which perl)
    bash_program="${stdenv.shell}" #$(which bash)

    sed -i -e "s:/usr/bin/env perl:$perl_program:" $src2/scripts/cd2nroff

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    echo PKG_CONFIG_PATH=$PKG_CONFIG_PATH

    CFLAGS="$NIX_CFLAGS_COMPILE"
    LDFLAGS="$NIX_LDFLAGS -Wl,-rpath,$out/lib -Wl,-enable-new-dtags"

    echo CFLAGS="$CFLAGS"
    echo LDFLAGS="$LDFLAGS"

    (cd $builddir && $bash_program $src2/configure --prefix=$out --with-openssl=${openssl} CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" --enable-shared)

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

  '';

  buildInputs = [ perl
                  openssl ];
}
