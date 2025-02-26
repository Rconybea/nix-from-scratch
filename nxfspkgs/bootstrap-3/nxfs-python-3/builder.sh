#!/bin/bash

echo "gcc_wrapper=${gcc_wrapper}"
echo "binutils=${binutils}"
echo "findutils=${findutils}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "zlib=${zlib}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -e
set -x

export PATH="${gcc_wrapper}/bin:${binutils}/bin:${findutils}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. substitute nix-store path-to-bash for /bin/sh.
#
#
#chmod -R +w ${src2}
#(cd ${src2} && ${bash_program} ${m4_patch})
#chmod -R -w ${src2}

# Must skip:
#   .m4 and .in files (assume they trigger re-running autoconf)
#   test/ files
#
#sed -i -e "s:/bin/sh:${bash_program}:g" ${src2}/configure #${src2}/build-aux/*

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

CFLAGS="-I${zlib}/include"
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

