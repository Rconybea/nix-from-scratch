#!/bin/bash

echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "findutils=${findutils}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "nxfs_system=${nxfs_system}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "sysroot=${sysroot}"
echo "zlib=${zlib}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -e
set -x

# 1. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 2. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 3. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 4. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${findutils}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}
mkdir ${source}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

chmod -R +w ${src2}

# ----------------------------------------------------------------
# replace /bin/sh with nix-store bash when invoking subprocesses
# ----------------------------------------------------------------

pushd ${src2}/Lib

sed -i -e "s:'/bin/sh':'"${bash_program}"':" subprocess.py

popd

# ----------------------------------------------------------------
# interpolate nxfs_system() instead of glibc system()
# nxfs_system uses nix-store bash instead of /bin/sh
# ----------------------------------------------------------------

pushd ${src2}/Modules

dest_c=posixmodule.c

sed -i -e '/Legacy wrapper/ i\
static int nxfs_system(const char* line);\
' ${dest_c}

nxfs_system_src=${nxfs_system}/src/nxfs_system.c

# use nxfs_system() instead of glibc system() to implement python's system() builtin
#
sed -i -e "s:system(bytes):nxfs_system(bytes):" ${dest_c}

# add definition of nxfs_system() to builtin.c
#
cat ${nxfs_system_src} >> ${dest_c}

popd

# ----------------------------------------------------------------
# Must skip:
#   .m4 and .in files (assume they trigger re-running autoconf)
#   test/ files
#
#sed -i -e "s:/bin/sh:${bash_program}:g" ${src2}/configure #${src2}/build-aux/*

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

CFLAGS="-I${zlib}/include -I${sysroot}/usr/include"
LDFLAGS="-Wl,-rpath=${out}/lib -L${zlib}/lib -Wl,-rpath=${zlib}/lib"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.
#
# 3.
# we don't have expat in nix store, at this point in bootstrap -> no --with-system-expat
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
(cd ${builddir} && ${bash_program} ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --enable-shared --enable-optimizations CC="nxfs-gcc" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}")

(cd ${builddir} && make SHELL=${CONFIG_SHELL})
(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

(cd ${src2} && (tar cf - . | tar xf - -C ${source}))
