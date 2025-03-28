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
  bison     = nxfsenv.bison;
  texinfo   = nxfsenv.texinfo;
  m4        = nxfsenv.m4;
  python    = nxfsenv.python;
  patchelf  = nxfsenv.patchelf;
  gzip      = nxfsenv.gzip;
  patch     = nxfsenv.patch;
  gperf     = nxfsenv.gperf;
  coreutils = nxfsenv.coreutils;
  bash      = nxfsenv.bash;
  gnutar    = nxfsenv.gnutar;
  gnumake   = nxfsenv.gnumake;
  gawk      = nxfsenv.gawk;
  gnused    = nxfsenv.gnused;
  gnugrep   = nxfsenv.gnugrep;
  binutils  = nxfsenv.binutils;
  diffutils = nxfsenv.diffutils;
  findutils = nxfsenv.findutils;
  which     = nxfsenv-3.which;

  nxfs-defs = nxfsenv.nxfs-defs;
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
in

# PLAN
#   - building with nxfs-toolchain-1 (redirected crosstool-ng toolchain):
#     compiler expects to use binutils from the crosstool-ng toolchain
#   - in this derivation building glibc from source from within nix environment
#
nxfsenv.mkDerivation {
  name           = "nxfs-glibc-stage1-3";
  version        = "2.40";

  # reminder: for __noChroot to take effect, needs nix.conf to contain:
  #   sandbox    = relaxed
  #
  #__noChroot    = true;

  system         = builtins.currentSystem;

  locale_archive = locale-archive;
  toolchain      = toolchain;
  sysroot        = sysroot;

  patchfile      = ./glibc-2.40-fhs-1.patch;

  src            = nixified-glibc-source;

#  src            = builtins.fetchTarball { name   = "glibc-2.40-source";
#                                           url    = "https://ftp.gnu.org/gnu/glibc/glibc-2.40.tar.xz";
#                                           sha256 = "0ncvsz2r8py3z0v52fqniz5lq5jy30h0m0xx41ah19nl1rznflkh";
#                                       };

  outputs      = [ "out" "source" ];

#  target_tuple = nxfs-defs.target_tuple;

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

#    chmod -R +w $src2

#    pushd $src2

#    sed -i -e 's:\$(localstatedir)/db:\$(localstatedir)/lib/nss_db:' ./Makeconfig
#    sed -i -e 's:/var/db/nscd/:/var/cache/nscd/:' ./nscd/nscd.h
#    sed -i -e 's:VAR_DB = /var/db:VARDB = /var/lib/nss_db:' ./nss/db-Makefile
#    sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/generic/paths.h
#    sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/unix/sysv/linux/paths.h
#
#    sed -i -e "s:/bin/bash:$bash_program:" ./Makefile
#    sed -i -e "s:/bin/sh:$bash_program:" ./sysdeps/generic/paths.h
#    sed -i -e "s:/bin/sh:$bash_program:" ./sysdeps/unix/sysv/linux/paths.h
#
#    sed -i -e '/^define SHELL_NAME/ s:"sh":"bash":' -e "s:/bin/sh:$bash_program:" ./sysdeps/posix/system.c
#
#    sed -i -e "s:/bin/sh:$bash_program:" ./libio/oldiopopen.c
#   sed -i -e "s:/bin/sh:$bash_program:" ./scripts/build-many-glibcs.py
#    sed -i -e "s:/bin/sh:$bash_program:" ./scripts/cross-test-ssh.sh
#    sed -i -e "s:/bin/sh:$bash_program:" ./scripts/config.guess
#    sed -i -e "s:/bin/sh:$bash_program:" ./scripts/dso-ordering-test.py
#    sed -i -e "s:/bin/sh:$bash_program:" ./posix/tst-vfork3.c
#    sed -i -e "s:/bin/sh:$bash_program:" ./posix/test-errno.c
#    sed -i -e "s:/bin/sh:$bash_program:" ./posix/tst-fexecve.c
#    sed -i -e "s:/bin/sh:$bash_program:" ./posix/tst-spawn3.c
#    sed -i -e "s:/bin/sh:$bash_program:" ./posix/tst-execveat.c
#    sed -i -e "s:/bin/sh:$bash_program:" ./posix/bug-regex9.c
#    sed -i -e "s:/bin/sh:$bash_program:" ./elf/tst-valgrind-smoke.sh
#    sed -i -e "s:/bin/sh:$bash_program:" ./debug/xtrace.sh

#    find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/sh:#!'$bash_program':' xx
#    find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/bash:#!'$bash_program':' xx
#    find . -type f | xargs --replace=xx sed -i -e '1s:#! */usr/bin/python3:#!'$python_program':' xx

#    # patch: fix bad function signature on locfile_hash() in locfile-kw.h, and charmap_hash() in charmap-kw.h
#    #
#    sed -i -e '/^locfile_hash/s:register unsigned int len:register size_t len:' locale/programs/locfile-kw.h
#    sed -i -e '/^charmap_hash/s:register unsigned int len:register size_t len:' locale/programs/charmap-kw.h

#    # note: the 'locale' program does not honor this.  However setlocale() does.
#    export LOCPATH=$locale_archive/lib/locale

#    find $src2 -name '*.awk' | xargs --replace={} sed -i -e 's:LC_ALL=C sort -u:lc-all-sort-wrapper -u:' {}
#    find $src2 -name '*.awk' | xargs --replace={} sed -i -e 's:sort -t:'$sort_program' -t:' -e 's:sort -u:'$sort_program' -u:' {}
#    (find $src2 -name '*.awk' | xargs --replace={} grep sort {} ) || true

#    set +e
#
#    (grep -n -R '/bin/sh' . | grep -v nix/store)
#    (grep -n -R '/bin/bash' . | grep -v nix/store)
#
#    set -e

#    popd

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
