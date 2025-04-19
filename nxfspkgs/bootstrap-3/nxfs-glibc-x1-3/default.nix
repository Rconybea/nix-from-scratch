{
  # everything in nxfsenv is from bootstrap-2/
  #  nxfsenv :: { mkDerivation, ... }
  nxfsenv,
  #  nxfsenv-3 :: { coreutils, ... }
  nxfsenv-3,

  # nixify-glibc-soruce :: attrset -> derivation
  nixify-glibc-source,

  # lc-all-sort :: derivation
  lc-all-sort,

  # locale-archive :: derivation
  locale-archive,

  # toolchain-wrapped :: derivation (wrapped version)
  toolchain-wrapper,
  # toolchain :: derivation  (unwrapped version)
  toolchain,
  # sysroot :: derivation
  sysroot,
} :

let
  bison     = nxfsenv-3.bison;
  texinfo   = nxfsenv-3.texinfo;
  m4        = nxfsenv.m4;
  python    = nxfsenv-3.python;
  patchelf  = nxfsenv-3.patchelf;
  gzip      = nxfsenv-3.gzip;
  patch     = nxfsenv-3.patch;
  gperf     = nxfsenv-3.gperf;
  coreutils = nxfsenv.coreutils;
  bash      = nxfsenv.bash;
  gnutar    = nxfsenv.gnutar;
  gnumake   = nxfsenv.gnumake;
  gawk      = nxfsenv.gawk;
  gnused    = nxfsenv.gnused;
  gnugrep   = nxfsenv.gnugrep;
  binutils  = nxfsenv.binutils;
  diffutils = nxfsenv-3.diffutils;
  findutils = nxfsenv.findutils;
  which     = nxfsenv-3.which;

  nxfs-defs = nxfsenv-3.nxfs-defs;
in

let
  # nixified-glibc-source :: derivation
  nixified-glibc-source = nixify-glibc-source {
    bash = bash;
    python = python;
    coreutils = coreutils;
    findutils = findutils;
    grep = gnugrep;
    tar = gnutar;
    sed = gnused;
    nxfs-defs = nxfs-defs;
  };

  version = "2.40";
in

# PLAN
#   - building with nxfs-toolchain-1 (redirected crosstool-ng toolchain):
#     compiler expects to use binutils from the crosstool-ng toolchain
#   - in this derivation building glibc from source from within nix environment
#
nxfsenv.mkDerivation {
  name           = "nxfs-glibc-stage1-3";
  version        = "2.40";

  system         = builtins.currentSystem;

  locale_archive = locale-archive;
  toolchain      = toolchain;
  sysroot        = sysroot;

  patchfile      = ./glibc-2.40-fhs-1.patch;

  src            = nixified-glibc-source;

  outputs      = [ "out" "source" ];

  buildPhase = ''
    # See also
    #  https://www.linuxfromscratch.org/lfs/view/12.2/chapter05/glibc.html

    set -e

    export PATH=$PATH:$toolchain/x86_64-pc-linux-gnu/bin

    mkdir -p $out
    mkdir -p $source

    src2=$TMPDIR/src2
    builddir=$TMPDIR/build

    mkdir -p $src2
    mkdir -p $builddir

    bash_program=$(which bash)
    python_program=$(which python3)
    sort_program=$(which sort)

    # 1. copy source tree to temporary directory
    #
    (cd $src && (tar cf - . | tar xf - -C $src2))

    export CONFIG_SHELL="$bash_program"

    pushd $builddir

    echo "rootsbindir=$out/sbin" > configparms

    # headers from toolchain
    #
    # libc_cv_complocaledir: this sets compiled-in default locale directory.
    # We need something that comes from the nix store so that basic locale queries
    # work from within isolated nix builds
    #
    bash $src2/configure --prefix=$out --enable-kernel=4.19 --with-headers=$sysroot/usr/include --disable-nscd libc_cv_complocaledir=$locale_archive/lib/locale libc_cv_slibdir=$out/lib CC=nxfs-gcc CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

    # looks like
    #   make Versions.v.i
    # fails in nix-build because of stray reference to /bin/sh
    # we understand that the configure step does write/modify files in $src2
    #
    (cd $src2 && (grep -n -R '/bin/sh' . | grep -v nix/store))

    # The compiler (nxfs-gcc, from ../nxfs-gcc-wrapper-2), that we passed to configure,
    # automatically makes two link-time changes when it builds a library/executable
    # 1. sets ELF interpreter to specific dynamic linker
    # 2. sets RPATH/RUNPATH to pickup libc
    # both coming from nix-from-scratch/nxfspkgs/bootstrap-1/nxfs-sysroot-1.
    #
    # We need that behavior above, to convince configure that compiler builds working executables.
    # However its counterproductive when we build libc, and hence also on executables that depend on it}.
    #
    # Use the backdoor environment variable NXFS_SYSROOT_DIR to get nxfs-gcc to use
    # the {ld-linux-x86-64.so.2, glibc} that we're building here.
    #
    export NXFS_SYSROOT_DIR=$out

    #(cd $builddir && make help SHELL=$CONFIG_SHELL)
    #/usr/bin/strace -f -e trace=openat make all SHELL=$CONFIG_SHELL
    export SHELL=$CONFIG_SHELL

    # Some things that can make build fail in chrooted build:
    # 1. gnumake $(shell ...) invoking /bin/sh
    #    (instead of bash from nxfs-bash-2)
    #    Fixed by building nxfs-gnumake-2 after nxfs-bash-2,
    #    + redirecting some /bin/sh references to nix-store
    # 2. gawk system() builtin invoking unaltered system() from glibc
    #    (which tries to invoke /bin/sh, as mandated by POSIX).
    #    Fix by writing snowflake version of system(), and splicing
    #    into nxfs-gawk-2.  See nxfs-system-2

    make all SHELL=$CONFIG_SHELL

    # Final cleanup -- nxfs-gcc will create an RPATH entry in
    #   {libc.so.6, ld-linux-x86-64.so.2}
    # In other libs/exes the inserted RPATH tells them how to find libc;
    # we don't want that in libc itself,  and RPATH is unnecessary in the
    # the dynamic linker
    #
    patchelf --remove-rpath libc.so.6
    patchelf --remove-rpath elf/ld-linux-x86-64.so.2

    make install SHELL=$CONFIG_SHELL

    patchelf --remove-rpath $out/lib/libc.so.6

    (cd $src2 && (tar cf - . | tar xf - -C $source))
  '';

  buildInputs = [ lc-all-sort
                  patchelf
                  gperf
                  python
                  texinfo
                  bison
                  toolchain-wrapper
                  toolchain
                  sysroot
                  gzip
                  diffutils
                  findutils
                  gnumake
                  gnutar
                  gawk
                  gnugrep
                  gnused
                  coreutils
                  patch
                  bash
                  which
                ];
}
