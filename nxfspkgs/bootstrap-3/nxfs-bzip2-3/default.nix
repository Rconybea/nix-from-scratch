{
  # nxfsenv-3 :: { mkDerivation :: attrs -> derivation,
  #                  gcc :: derivation,
  #                  binutils    :: derivation,
  #                  gawk        :: derivation,
  #                  gnumake     :: derivation,
  #                  gnugrep     :: derivation,
  #                  gnutar      :: derivation,
  #                  gnused      :: derivation,
  #                  coreutils   :: derivation,
  #                  bash        :: derivation,
  #                  glibc       :: derivation,
  #                  nxfs-defs   :: { target_tuple :: string }
  #                }
  nxfsenv-3,
  patchelf
} :

let
  patch = nxfsenv-3.patch;
  findutils = nxfsenv-3.findutils;
  diffutils = nxfsenv-3.diffutils;
  gcc = nxfsenv-3.gcc;
  binutils = nxfsenv-3.binutils;
  gawk = nxfsenv-3.gawk;
  gnumake = nxfsenv-3.gnumake;
  gnugrep = nxfsenv-3.gnugrep;
  gnutar = nxfsenv-3.gnutar;
  gnused = nxfsenv-3.gnused;
  coreutils = nxfsenv-3.coreutils;
  bash = nxfsenv-3.bash;

  version = "1.0.8";
in

nxfsenv-3.mkDerivation {
  name         = "nxfs-bzip2-3";
  version      = version;
  system       = builtins.currentSystem;

  src          = builtins.fetchTarball { name = "bzip2-${version}-source";
                                         url = "https://www.sourceware.org/pub/bzip2/bzip2-${version}.tar.gz";
                                         sha256 = "1a0pl9gq1iny210b0vkrf4lp0hjcks3cmf19hfvi44fgjcjviy2j"; };

  patchFile1 = ./bzip2-${version}-install-docs-1.patch;

  buildPhase = ''
    builddir=$TMPDIR
    bash_program=$bash/bin/bash

    # have to build in source directory..
    (cd $src && (tar cf - . | tar xf - -C $builddir))
    chmod -R +w $builddir

    pushd $builddir

    #patch -Np1 -i $patchFile1

    # remove $(PREFIX)/bin/ prefixes so symlinks are installed as relative paths
    sed -i 's:\(ln -s -f \)$(PREFIX)/bin/:\1:' Makefile

    # fix man page install location
    sed -i 's:(PREFIX)/man:(PREFIX)/share/man:g' Makefile

    sed -i "s:/bin/sh:$bash_program:" Makefile Makefile-libbz2_so

    LDFLAGS="-Wl,-rpath=$out/lib -Wl,-enable-new-dtags"

    make -f Makefile-libbz2_so "LDFLAGS=$LDFLAGS"
    make clean "LDFLAGS=$LDFLAGS"
    make "LDFLAGS=$LDFLAGS"

    make PREFIX=$out "LDFLAGS=$LDFLAGS" install

    # for some reason LDFLAGS isn't effective on bzip2-shared..
    patchelf --add-rpath $out/lib bzip2-shared
    cp -v bzip2-shared $out/bin/bzip2

    cp -av libbz2.so* $out/lib
    ln -sv libbz2.so.1.0 $out/lib/libbz2.so
  '';

  buildInputs = [
    gcc
    binutils
    patchelf
    patch
    gawk
    gnumake
    gnugrep
    gnutar
    gnused
    coreutils
    diffutils
    findutils
    bash
  ];
}
