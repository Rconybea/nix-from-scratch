{
  # nxfsenv   :: { mkDerivation :: attrs -> derivation,
  #                gcc-wrapper :: derivation  (also as gcc_wrapper)
  #                binutils    :: derivation
  #                perl        :: derivation
  #                gawk        :: derivation
  #                gnumake     :: derivation
  #                gnugrep     :: derivation
  #                gnutar      :: derivation
  #                gnused      :: derivation
  #                coreutils   :: derivation
  #                bash        :: derivation
  #                glibc       :: derivation
  #                nxfs-defs   :: { target_tuple :: string }
  #              }
  nxfsenv,
  # nxfsenv-3 :: {
  #                pkgconf     :: derivation
  #                coreutils   :: derivation
  #                gnumake     :: derivation
  #                gawk        :: derivation
  #                bash        :: derivation
  #                gnutar      :: derivation
  #                gnugrep     :: derivation
  #                gnused      :: derivation
  #                findutils   :: derivation
  #                diffutils   :: derivation
  #              }
  nxfsenv-3,
  # libxcrypt :: derivation
  libxcrypt
} :

let
  version_major_minor = "5.40";
  version = "5.40.0";
in

nxfsenv.mkDerivation {
  name         = "nxfs-perl-3";

  libxcrypt    = libxcrypt;

  gcc_wrapper  = nxfsenv.gcc_wrapper;

  version             = version;
  version_major_minor = version_major_minor;

  src                 = builtins.fetchTarball { name = "perl-${version}-source";
                                                sha256 = "1yiqddm0l774a87y13jmqm6w0j0dja7ycnigzkkbsy7gm5bkb8ig";
                                                url = "https://www.cpan.org/src/5.0/perl-${version}.tar.xz"; };

  buildPhase = ''
    set -e

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

    bash_program=$bash/bin/bash

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    perlout=$out/lib/perl5/$version_major_minor

    cd $builddir

    CCFLAGS="-DNO_LOCALE -v"
    LDFLAGS="-L$libxcrypt/lib -Wl,-rpath,$libxcrypt/lib -Wl,-enable-new-dtags"

    # -e: stop questions after config.sh
    # -s: silent mode
    #
    sh Configure -de -Dperl_lc_all_uses_name_value_pairs=define -Dcc=$gcc_wrapper/bin/nxfs-gcc -Dcflags="$CCFLAGS" -Dldflags="$LDFLAGS" -Dprefix=$out -Dvendorprefix=$out -Duseshrplib -Dprivlib=$perlout/core_perl -Darchlib=$perlout/core_perl -Dsitelib=$perlout/site_perl -Dsitearch=$perlout/site_perl -Dvendorlib=$perlout/vendor_perl -Dvendorarch=$perlout/vendor_perl

    make SHELL=$CONFIG_SHELL

    make install SHELL=$CONFIG_SHELL

  '';

  buildInputs = [ libxcrypt
                  nxfsenv.gcc_wrapper
                  nxfsenv.binutils
                  nxfsenv-3.pkgconf
                  nxfsenv-3.gnumake
                  nxfsenv-3.gawk
                  nxfsenv-3.gnutar
                  nxfsenv-3.gnugrep
                  nxfsenv-3.gnused
                  nxfsenv-3.findutils
                  nxfsenv-3.diffutils
                  nxfsenv.coreutils
                  nxfsenv-3.bash ];
}
