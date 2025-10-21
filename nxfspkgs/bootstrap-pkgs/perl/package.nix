{
  # stdenv :: derivation+attrset
  stdenv,
  # libxcrypt :: derivation|null
  libxcrypt ? null,
  # pkgconf :: derivation
  pkgconf,
  # with-xcrypt :: bool
  with-xcrypt ? libxcrypt != null,
  # locale-archive :: derivation
  locale-archive,
  # stageid :: string -- "2" for stage2, "3" for stage3
  stageid,
} :

let
  version_major_minor = "5.38";
  version = "5.38.2";
  with_xcrypt = with-xcrypt;
in

stdenv.mkDerivation {
  name         = "nxfs-perl-${stageid}";

  inherit libxcrypt;

  #gcc_wrapper  = nxfsenv.gcc_wrapper;

  version             = version;
  version_major_minor = version_major_minor;

  src                 = builtins.fetchTarball { name = "perl-${version}-source";
                                                sha256 = "sha256:1ddz3rqimsrlhzp786hg0z9yldj2866mckbkkgz0181yasdivwad";
                                                url = "https://www.cpan.org/src/5.0/perl-${version}.tar.xz"; };

  buildPhase = ''
    set -e

    echo "PATH=$PATH"
    echo "NIX_CFLAGS_COMPILE=$NIX_CFLAGS_COMPILE"
    echo "NIX_LDFLAGS=$NIX_LDFLAGS"

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

    #CFLAGS="-DNO_LOCALE -v"   # this does.. something.
    CFLAGS=

    ${if with_xcrypt then ''
      LDFLAGS="-L$libxcrypt/lib -Wl,-rpath,$libxcrypt/lib -Wl,-enable-new-dtags"
    '' else ''
      LDFLAGS="-Wl,-enable-new-dtags"
    ''}

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    sh Configure -de -Dperl_lc_all_uses_name_value_pairs=define \
        -Dcc=$CC -Dcflags="$NIX_CFLAGS_COMPILE" \
        -Dldflags="$NIX_LDFLAGS" \
        -Dprefix=$out \
        -Dvendorprefix=$out \
        -Duseshrplib \
        -Dprivlib=$perlout/core_perl \
        -Darchlib=$perlout/core_perl \
        -Dsitelib=$perlout/site_perl \
        -Dsitearch=$perlout/site_perl \
        -Dvendorlib=$perlout/vendor_perl \
        -Dvendorarch=$perlout/vendor_perl

    make SHELL=$CONFIG_SHELL
    make install SHELL=$CONFIG_SHELL

  '';

  buildInputs = [ pkgconf locale-archive ] ++ (if with_xcrypt then [ libxcrypt ] else []);
}
