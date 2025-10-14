{
  # nxfsenv :: attrset
  nxfsenv,
} :

let
  patchelf  = nxfsenv.patchelf;
  patch     = nxfsenv.patch;
  findutils = nxfsenv.findutils;
  diffutils = nxfsenv.diffutils;
  gcc       = nxfsenv.gcc_wrapper;
  binutils  = nxfsenv.binutils;
  gawk      = nxfsenv.gawk;
  gnumake   = nxfsenv.gnumake;
  gnugrep   = nxfsenv.gnugrep;
  gnutar    = nxfsenv.gnutar;
  gnused    = nxfsenv.gnused;
  coreutils = nxfsenv.coreutils;
  bash      = nxfsenv.shell;

  version   = "1.0.8";
in

nxfsenv.mkDerivation {
  name         = "nxfs-bzip2-3";
  version      = version;
  system       = builtins.currentSystem;

  src          = builtins.fetchTarball { name = "bzip2-${version}-source";
                                         url = "https://www.sourceware.org/pub/bzip2/bzip2-${version}.tar.gz";
                                         sha256 = "1a0pl9gq1iny210b0vkrf4lp0hjcks3cmf19hfvi44fgjcjviy2j"; };

  patchFile1 = ./bzip2-${version}-install-docs-1.patch;

  patchPhase = ''
    echo "welcome to bzip2 custom patch phase"
    echo src=$src

    builddir=$TMPDIR

    # have to build in source directory..
    (cd $src && (tar cf - . | tar xf - -C $builddir))
    chmod -R +w $builddir

    pushd $builddir
    sed -i -e '/cat words/d' Makefile

    popd
  '';

  buildPhase = ''
    set -x

    builddir=$TMPDIR
    bash_program=$bash/bin/bash

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
    make -v PREFIX=$out "LDFLAGS=$LDFLAGS" install >&2

    mkdir -p $out/bin $out/lib

    # for some reason LDFLAGS isn't effective on bzip2-shared..
    patchelf --add-rpath $out/lib bzip2-shared

    cp -v bzip2-shared $out/bin/bzip2

    cp -av libbz2.so* $out/lib
    ln -sv libbz2.so.1.0 $out/lib/libbz2.so

    popd
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
