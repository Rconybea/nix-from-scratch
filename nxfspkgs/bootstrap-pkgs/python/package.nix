{
  # stdenv :: attrset+derivation
  stdenv,
  # fetchurl :: {url|urls,
  #              hash|sha256|sha512|sha1|md5,
  #              name,
  #              curlOpts|curlOptsList,
  #              postFetch, downloadToTemp,
  #              impureEnvVars, meta, passthru, preferLocalBuild} -> derivation
  fetchurl,
  # popen :: derivation
  popen,
  # zlib :: derivation
  zlib,
  # stageid :: string  -- "2" for stage2, "3" for stage3 etc.
  stageid,
} :

let
  nxfs-defs = import ../nxfs-defs.nix;

  version = "3.12.6";
in

stdenv.mkDerivation {
  name         = "nxfs-python-${stageid}";
  version      = version;

  inherit popen zlib;

  src          = fetchurl { name = "python-${version}-source.tar.xz";
                            url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
                            hash = "sha256-GZllgpjPL7g33/7Y/zwDPvDJjvIM9zxdX2a+1auJaXw=";
                            #sha256 = "0ggdm1l4dhr3qn0rwzjha5r15m3mfyl0hj8j89xip7jx10mip952";
                          };

  buildPhase = ''
    echo "popen=$popen"
    echo "zlib=$zlib"

    echo "NIX_CFLAGS_COMPILE=$NIX_CFLAGS_COMPILE"
    echo "NIX_LDFLAGS=$NIX_LDFLAGS"

    set -e

    sourceDir=$(pwd)
    #src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    #mkdir -p $src2
    mkdir -p $builddir

    ## 1. copy source tree to temporary directory,
    ##
    #(cd $src && (tar cf - . | tar xf - -C $src2))
    #
    #chmod -R +w $src2

    # ----------------------------------------------------------------
    # replace /bin/sh with nix-store bash when invoking subprocesses
    # ----------------------------------------------------------------

    pushd $sourceDir/Lib

    sed -i -e "s:'/bin/sh':'"${stdenv.shell}"':" subprocess.py

    popd

    # ----------------------------------------------------------------
    # interpolate nxfs_system() instead of glibc system()
    # nxfs_system uses nix-store bash instead of /bin/sh
    # ----------------------------------------------------------------

    pushd $sourceDir/Modules

    dest_c=posixmodule.c

    sed -i -e '/Legacy wrapper/ i\
    static int nxfs_system(const char* line);\
    ' $dest_c

    nxfs_system_src=$popen/src/nxfs_system.c

    # use nxfs_system() instead of glibc system() to implement python's system() builtin
    #
    sed -i -e "s:system(bytes):nxfs_system(bytes):" $dest_c

    # add definition of nxfs_system() to builtin.c
    #
    cat $nxfs_system_src >> $dest_c

    popd

    # $sourceDir/configure honors CONFIG_SHELL
    export CONFIG_SHELL="${stdenv.shell}"

    CFLAGS="$NIX_CFLAGS_COMPILE" #-I$zlib/include
    LDFLAGS="-Wl,-rpath=$out/lib $NIX_LDFLAGS"

    # 1.
    # we shouldn't need special compiler/linker instructions,
    # since stage-1 toolchain "knows where it lives"
    #
    # 2.
    # do need to give --host and --build arguments to configure,
    # since we're using a cross compiler.
    #
    # 3.
    # at this point in bootstrap we don't have expat in nix store -> no --with-system-expat
    #
    # 4.
    # not building these optional modules
    #   _bz2
    #   _ctypes_test
    #   _dbm
    #   _lzma
    #   _uuid
    #   zlib
    #   _crypt
    #   _curses
    #   _gdbm
    #   _ssl
    #   nis
    #   _ctypes
    #   _curses_panel
    #   _hashlib
    #   _tkinter
    #   readline
    #
    (cd $builddir && $shell $sourceDir/configure --prefix=$out --enable-shared --enable-optimizations CC="nxfs-gcc" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)
    '';

  buildInputs = [ zlib ];
}
