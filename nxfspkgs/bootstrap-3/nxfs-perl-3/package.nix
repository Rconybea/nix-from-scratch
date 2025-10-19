{
  # stdenv :: derivation+attrset
  stdenv,
  # libxcrypt :: derivation
  libxcrypt,
  # pkgconf :: derivation
  pkgconf,
} :

let
  version_major_minor = "5.40";
  version = "5.40.0";
in

stdenv.mkDerivation {
  name         = "nxfs-perl-3";

  inherit libxcrypt;

  #gcc_wrapper  = nxfsenv.gcc_wrapper;

  version             = version;
  version_major_minor = version_major_minor;

  src                 = builtins.fetchTarball { name = "perl-${version}-source";
                                                sha256 = "1yiqddm0l774a87y13jmqm6w0j0dja7ycnigzkkbsy7gm5bkb8ig";
                                                url = "https://www.cpan.org/src/5.0/perl-${version}.tar.xz"; };

  buildPhase = ''
    set -e

    echo "PATH=$PATH"

    set -x

    src2=$TMPDIR/src2
    # perl builds in source tree
    builddir=$src2

    mkdir -p $src2

    # 1. copy source tree to temporary directory,
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    # 2. since we're building in source tree,
    #    will need to be able to write there
    #
    chmod -R +w $src2

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL=$shell

    perlout=$out/lib/perl5/$version_major_minor

    cd $builddir

    CCFLAGS="-DNO_LOCALE -v"
    LDFLAGS="-L$libxcrypt/lib -Wl,-rpath,$libxcrypt/lib -Wl,-enable-new-dtags"

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    sh Configure -de -Dperl_lc_all_uses_name_value_pairs=define -Dcc=$CC -Dcflags="$CCFLAGS" -Dldflags="$LDFLAGS" -Dprefix=$out -Dvendorprefix=$out -Duseshrplib -Dprivlib=$perlout/core_perl -Darchlib=$perlout/core_perl -Dsitelib=$perlout/site_perl -Dsitearch=$perlout/site_perl -Dvendorlib=$perlout/vendor_perl -Dvendorarch=$perlout/vendor_perl

    make SHELL=$CONFIG_SHELL
    make install SHELL=$CONFIG_SHELL

  '';

  buildInputs = [ libxcrypt pkgconf ];
}
