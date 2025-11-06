{
  # attrset+derivation
  stdenv,
  # nixified-gcc-source :: derivation
  nixified-gcc-source,
  # gcc-wrapper :: derivation
  gcc-wrapper,
  # binutils-stage1-wrapper-2 :: derivation
  binutils-wrapper,
  # mpc :: derivation
  mpc,
  # mpfr :: derivation
  mpfr,
  # gmp :: derivation
  gmp,
  # isl :: derivation
  isl,
  # bison :: derivation
  bison,
  # flex :: derivation
  flex,
  # texinfo :: derivation
  texinfo,
  # m4 :: derivation
  m4,
  # libstdxx :: derivation   -- same as gcc-wrapper.libstdcxx -- not used here
  libstdcxx,
  # glibc :: derivation
  glibc,
  # nxfs-defs :: derivation
  nxfs-defs,
  # stageid :: string  -- "x3-2" for x3 stage2, "x4-2" for x4 stage2 etc.
  stageid,
} :

stdenv.mkDerivation {
  name         = "nxfs-gcc-${stageid}";
  # e.g. 14.2.0
  version      = nixified-gcc-source.version;
  system       = builtins.currentSystem;

  inherit mpc mpfr gmp isl flex glibc;

  libc = glibc;

  src          = nixified-gcc-source;

  target_tuple = nxfs-defs.target_tuple;

  buildPhase = ''
    # See also
    #   https://gcc.gnu.org/install/configure.html

    set -e

    echo PATH=$PATH

    #src2=$src
    builddir=$TMPDIR/build

    mkdir -p $builddir
    mkdir -p $out/lib

    # don't want separate /lib and /lib64 dirs.
    # only supporting 64-bit builds here
    #
    (cd $out && ln -sf lib lib64)

    mkdir -p $out/$target_tuple/lib

    bash_program=$shell

    # $src/configure honors CONFIG_SHELL
    export CONFIG_SHELL="$bash_program"

    # --disable-nls:                    no internationalization.  don't need during bootstrap
    # --disable-fixincludes:            intended for compatibility with old OS platforms with broken system headers.
    #                                   enables subtle use of #include_next
    # --enable-gprofng=no:              don't need gprofng tool during bootstrap
    # --disable-werror:                 don't treat compiler warnings as errors
    # --enable-default-hash-style=gnu:  only generate faster gnu-style symbol hash table by default.
    #
    # linuxfromscratch sets --sysroot=$LFS.
    # We think we don't need this, since gcc-wrapper points built executables/libraries to libc etc in $sysroot
    #
    # Variation w.r.t. linuxfromscratch
    #   --with-newlib               don't compile libc-dependent code (we have some other libc from sysroot)
    #   --with-sysroot              should not need this.   Not planning to chroot anywhere
    #   --without-headers           will need kernel headers compatible with target.  Don't look for them for now.
    #   --disable-shared            necessary so we can invoke gcc without libc
    #   --disable-multilib
    #
    # other interesting args we may adopt:
    #   --with-native-system-header-dir=dirname   look for native system headers here, instead of in /usr/include
    #                                             may want to point this at sysroot/usr/include
    #   --with-stage1-libs
    #   --with-stage1-ldflags
    #   --with-boot-libs
    #   --with-boot-ldflags

    set -x

    export C_INCLUDE_PATH="$glibc/include"
    #export CPLUS_INCLUDE_PATH="$libstdcxx/include/c++/$version:$libstdcxx/include/$version/$target_tuple:$glibc/include"
    export CPLUS_INCLUDE_PATH="$glibc/include"

    # CFLAGS: this is load-bearing. Otherwise may have failure in $src/libcody/buffer.c on #include_next <stdlib.h>
    export CFLAGS="-idirafter $glibc/include"
    # TODO: -O2

    LDFLAGS="-B$glibc/lib"
    LDFLAGS="$LDFLAGS -L$flex/lib -L$mpc/lib -L$mpfr/lib -L$isl/lib -L$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$mpc/lib -Wl,-rpath,$mpfr/lib -Wl,-rpath,$isl/lib -Wl,-rpath,$gmp/lib"
    LDFLAGS="$LDFLAGS -Wl,-rpath,$glibc/lib"
    export LDFLAGS

    CXXFLAGS_FOR_TARGET="-B$glibc/lib"
    export CXXFLAGS_FOR_TARGET

    LDFLAGS_FOR_TARGET="-B$glibc/lib -Wl,-rpath,$out/lib -Wl,-rpath,$glibc/lib"
    export LDFLAGS_FOR_TARGET

    LIBRARY_PATH=$out/lib:$glibc/lib
    export LIBRARY_PATH

    set +x

    # The wrapper (nxfs-gcc) injects compiler- and linker- flags to pull in glibc.
    # This works for much of the gcc build,  however the additional flags are lost when the gcc
    # built invokes freshly-build xgcc to build support libraries like libgcc_s.so.
    # This fails, because ld (from nxfs-binutils-2) can't find {crti.o, crtn.o, -lc}.
    #
    # Two ways we might try to fix this:
    #
    # A. Introduce a binutils wrapper for ld that reintroduces the missing flags.
    #    So ld{w} ... would invoke
    #      ld{u} -rpath=$NXFS_SYSROOT_DIR/lib -dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2 ...
    #
    # B. Notice that the xgcc invocation has -B flags for $out/$target_tuple/lib under our own $out dir,
    #    so we could try to copy (or, symlink) {crti.o,crtn.o,libc.so,} from there
    #    I expect this is problematic for the same reason we can't just copy libc.so: it expects to know where it lives.
    #
    ln -s $glibc/lib/crt1.o $out/$target_tuple/lib/crt1.o
    ln -s $glibc/lib/crti.o $out/$target_tuple/lib/crti.o
    ln -s $glibc/lib/crtn.o $out/$target_tuple/lib/crtn.o
    ln -s $glibc/lib/libc.so $out/$target_tuple/lib/libc.so
    ln -s $glibc/lib/libc.so.6 $out/$target_tuple/lib/libc.so.6
    ln -s $glibc/lib/Scrt1.o $out/$target_tuple/lib/Scrt1.o
    # omitting: Mcrt1.o, gcrt1.o grcrt1.o ld-linux-x86-64.so.2
    #           libBrokenLocale.so libBrokenLocale.so.1
    #           libanl.so libanl.so.1 etc.

    # NOTE: nxfs-gcc automatically inserts flags
    #
    #          -Wl,--rpath=$NXFS_SYSROOT_DIR/lib -Wl,--dynamic-linker=$NXFS_SYSROOT_DIR/lib/ld-linux-x86-64.so.2
    #       We still need them explictly here
    #
    (cd $builddir && $shell $src/configure \
                                   --prefix=$out \
                                   --disable-bootstrap \
                                   --disable-fixincludes \
                                   --disable-multilib \
                                   --disable-nls \
                                   --with-native-system-header-dir=$glibc/include \
                                   --with-gxx-include-dir=$out/include/c++/$version \
                                   --enable-lto \
                                   --with-mpc=$mpc --with-mpfr=$mpfr --with-gmp=$gmp --with-isl=$isl \
                                   --enable-default-pie \
                                   --enable-default-ssp \
                                   --enable-shared \
                                   --enable-threads \
                                   --enable-libatomic \
                                   --enable-libgomp \
                                   --enable-libquadmath \
                                   --enable-libssp \
                                   --enable-libvtv \
                                   --enable-libstdcxx \
                                   --enable-languages=c,c++ \
                                   --with-stage1-ldflags="-B$glibc/lib -Wl,-rpath,$out/lib -Wl,-rpath,$glibc/lib" \
                                   --with-boot-ldflags="-B$glibc/lib -Wl,-rpath,$out/lib -Wl,-rpath,$glibc/lib" \
                                   CC=nxfs-gcc CXX=nxfs-g++ CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS")

    (cd $builddir && make SHELL=$CONFIG_SHELL)
    (cd $builddir && make install SHELL=$CONFIG_SHELL)

    # build will produce binaries that include in RUNPATH directories from the bootstrap compiler
    # that nxfs-gcc invokes. Prune these here, since new compiler doesn't need them,
    # and they could interfere if loaded ahead of similarly named libraries owned by the new compiler
    #
    # Contrast with previous gcc build, where we needed to keep bootstrap libraries
    # in RUNPATH, but control ordering

    #prev_unwrapped_gcc="${gcc-wrapper.cc}";  # not needed, since we built full gcc here

    dynamic_linker=$glibc/lib/ld-linux-x86-64.so.2

    if [ ! -e $dynamic_linker ]; then
         echo "error: dynamic_linker [$dynamic_linker] not found"
         exit 1
    fi

    patchelf_exec() {
        target=$1
        rpath=$2

        patchelf --set-rpath $rpath $target
        patchelf --set-interpreter $dynamic_linker $target
    }

    set -x

    # for targets that need libc only
    rpath_a=$glibc/lib

    # for targets that need libc + {libstdc++, libgcc_s, libm}
    rpath_b=$out/lib:$glibc/lib
    # for targets that need {libmpc, libmpfr, libgmp, libisl, libc, libstdc++, libgcc_s, libm, libc}
    rpath_c=$out/lib:$mpc/lib:$mpfr/lib:$isl/lib:$gmp/lib:$libc/lib

    bindir=$out/bin

    patchelf_exec $bindir/cpp $rpath_b
    patchelf_exec $bindir/gcc $rpath_b
    patchelf_exec $bindir/g++ $rpath_b
    patchelf_exec $bindir/gcc-ar $rpath_b
    patchelf_exec $bindir/gcc-nm $rpath_b
    patchelf_exec $bindir/gcc-nm $rpath_b
    patchelf_exec $bindir/gcc-ranlib $rpath_b
    patchelf_exec $bindir/gcov $rpath_b
    patchelf_exec $bindir/gcov-dump $rpath_b
    patchelf_exec $bindir/gcov-tool $rpath_b
    patchelf_exec $bindir/lto-dump $rpath_c

    libdir=$out/lib

    patchelf --set-rpath $rpath_b $libdir/libasan.so
    patchelf --set-rpath $rpath_a $libdir/libatomic.so.1
    patchelf --set-rpath $rpath_a $libdir/libgcc_s.so.1
    patchelf --set-rpath $rpath_a $libdir/libgomp.so.1
    patchelf --set-rpath $rpath_b $libdir/libhwasan.so
    patchelf --set-rpath $rpath_a $libdir/libitm.so.1
    patchelf --set-rpath $rpath_b $libdir/liblsan.so
    patchelf --set-rpath $rpath_a $libdir/libquadmath.so
    patchelf --set-rpath $rpath_a $libdir/libssp.so
    patchelf --set-rpath $rpath_b $libdir/libstdc++.so
    patchelf --set-rpath $rpath_b $libdir/libtsan.so
    patchelf --set-rpath $rpath_b $libdir/libubsan.so

    patchelf --set-rpath $rpath_b $out/lib64/libcc1.so

    patchelf --set-rpath $rpath_b $libdir/gcc/$target_tuple/$version/plugin/libcp1plugin.so
    patchelf --set-rpath $rpath_b $libdir/gcc/$target_tuple/$version/plugin/libcc1plugin.so

    # also handle executables in $out/libexec/gcc/$target_tuple/$version

    execdir=$out/libexec/gcc/$target_tuple/$version

    patchelf_exec $execdir/cc1 $rpath_c
    patchelf_exec $execdir/cc1plus $rpath_c
    patchelf_exec $execdir/collect2 $rpath_b
    patchelf_exec $execdir/g++-mapper-server $rpath_b
    patchelf --set-rpath $rpath_a $execdir/liblto_plugin.so
    patchelf_exec $execdir/lto-wrapper $rpath_b
    patchelf_exec $execdir/lto1 $rpath_c

    # would need this iff --disable-fixincludes dropped
    #patchelf_exec $execdir/install-tools/fixincl $rpath_a

    patchelf_exec $execdir/plugin/gengtype $rpath_b

    ### also grapb specs and kitbash them for separate glibc location ###

    specfile=$out/lib/gcc/$target_tuple/$version/specs
    $out/bin/gcc -dumpspecs | sed -e "{
      s|:\([^;}:]*\)/\(ld-linux-x86-64.so.2}\)|:$glibc/lib/\2|g
      s|collect2|collect2 -L$glibc/lib -rpath $glibc/lib|
    }" | sed -e "/^\*link:$/{
        n
        s|^|-L$glibc/lib |
    }" > $specfile

    # also nuke at-best-misleading .la files
    rm -f $libdir/gcc/$target_tuple/$version/plugin/*.la
    rm -f $libdir/*.la
    rm -f $out/lib64/*.la
    rm -f $execdir/*.la

    # can now remove the toolchain(sysroot) debris we temporarily put into $out/$target_tuple
    rm $out/$target_tuple/lib/crt1.o
    rm $out/$target_tuple/lib/crti.o
    rm $out/$target_tuple/lib/crtn.o
    rm $out/$target_tuple/lib/libc.so
    rm $out/$target_tuple/lib/libc.so.6
    rm $out/$target_tuple/lib/Scrt1.o

    # also nuke build.env, since contains toolchain references
    rm -f $out/build.env

  '';

  # note: will appear in path left-to-right
  buildInputs  = [ gcc-wrapper
                   binutils-wrapper
                   bison
                   flex
                   texinfo
                   m4
                 ];

} // {
  # experiment
  # ----------
  # Encountered problem with nixpkgs builds-on-top-of-nxfs, where
  # it (specifically stdenv/generic/default.nix, invoked from stdenv2nix-minimal)
  # complains if nixpkgs.patchelf.stdenv.cc.cc doesn't advertise itself as coming
  # from bootstrapFiles.
  #
  # See:
  # - assertion (isBuiltByBootstrapFilesCompiler (prevStage).patchelf)
  #   in nixpkgs/pkgs/stdenv/linux/default.nix
  # - isBuiltByBootstrapFilesCompiler defined in nixpkgs/pkgs/stdenv/linux/default.nix
  #
  # Try setting this passthru, see if that unwedges
  #
  passthru.isFromBootstrapFiles = true;
}
