#!/bin/bash

# runs in build directory

set -euo pipefail

self_name=$(basename ${0})

usage() {
    cat <<EOF
$self_name: --archive-dir=ARCHIVE_DIR --prefix=PREFIX --target=TARGET
            --binutils=BINUTILS
            --linux-headers=LINUX_HEADERS
            --gmp=GMP --mpfr=MPFR --mpc=MPC --isl=ISL
            --max-jobs=MAXJOBS
EOF
}

# archive_dir: directory where wee keep tarballs
archive_dir=
prefix=
target=
binutils=
linux_headers=
gmp=
mpfr=
mpc=
isl=
gettext=
gcc=
glibc=
jobs=$(nproc)

while [[ $# > 0 ]]; do
    case "$1" in
        --archive-dir=*)
            archive_dir=${1#*=}
            ;;
        --prefix=*)
            prefix=${1#*=}
            ;;
        --target=*)
            target=${1#*=}
            ;;
        --binutils=*)
            binutils=${1#*=}
            ;;
        --linux-headers=*)
            linux_headers=${1#*=}
            ;;
        --gmp=*)
            gmp=${1#*=}
            ;;
        --mpfr=*)
            mpfr=${1#*=}
            ;;
        --mpc=*)
            mpc=${1#*=}
            ;;
        --isl=*)
            isl=${1#*=}
            ;;
        --gettext=*)
            gettext=${1#*=}
            ;;
        --gcc=*)
            gcc=${1#*=}
            ;;
        --glibc=*)
            glibc=${1#*=}
            ;;
        --max-jobs=*)
            jobs=${1#*=}
            ;;
        *)
            echo "error: ${self_name}: unexpected argument [$1]"
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${archive_dir} ]]; then
    echo "error: ${self_name}: expected non-empty ARCHIVE_DIR (use --archive-dir=ARCHIVE_DIR)"
    exit 1
fi

if [[ -z ${prefix} ]]; then
    echo "error: ${self_name}: expected non-empty PREFIX (use --prefix=PREFIX)"
    exit 1
fi

if [[ -z ${target} ]]; then
    echo "error: ${self_name}: expected non-empty TARGET (use --target=TARGET)"
    exit 1
fi

if [[ -z ${binutils} ]]; then
    echo "error: ${self_name}: expected non-empty BINUTILS tarball (use --binutils=BINUTILS)"
    exit 1
fi

if [[ -z ${linux_headers} ]]; then
    echo "error: ${self_name}: expected non-empty LINUX_HEADERS tarball (use --linux-headers=LINUX_HEADERS)"
    exit 1
fi

if [[ -z ${gmp} ]]; then
    echo "error: ${self_name}: expected non-empty GMP tarball (use --gmp=GMP)"
    exit 1
fi

if [[ -z ${mpfr} ]]; then
    echo "error: ${self_name}: expected non-empty MPFR tarball (use --mpfr=MPFR)"
    exit 1
fi

if [[ -z ${mpc} ]]; then
    echo "error: ${self_name}: expected non-empty MPC tarball (use --mpc=MPC)"
    exit 1
fi

if [[ -z ${isl} ]]; then
    echo "error: ${self_name}: expected non-empty MPC tarball (use --isl=ISL)"
    exit 1
fi

if [[ -z ${gettext} ]]; then
    echo "error: ${self_name}: expected non-empty MPC tarball (use --gettext=GETTEXT)"
    exit 1
fi

if [[ -z ${gcc} ]]; then
    echo "error: ${self_name}: expected non-empty GCC tarball (use --gcc=GCC)"
    exit 1
fi

if [[ -z ${glibc} ]]; then
    echo "error: ${self_name}: expected non-empty GLIBC tarball (use --glibc=GLIBC)"
    exit 1
fi

export PREFIX=${prefix}
export TARGET=${target}
export CROSS_PREFIX=${PREFIX}/cross
export TARGET_PREFIX=${CROSS_PREFIX}/${target}
export ARCH=x86
export PATH=${PREFIX}/bin:${CROSS_PREFIX}/bin:${PATH}

echo ARCHIVE_DIR=${archive_dir}
echo PREFIX=${prefix}
echo TARGET=${target}
echo CROSS_PREFIX=$CROSS_PREFIX
echo TARGET_PREFIX=$TARGET_PREFIX
echo ARCH=$ARCH
echo PATH=$PATH

echo binutils=${binutils}

################################################################
# step 0a. Environment

set -x

echo "### 0a. Generate build scripts"

pushd ..

toolchain_dir=$(pwd)

mkdir -p build
mkdir -p tools

# Makefile for build directory.
# Avoiding explicit tabs here to route around IDE 'help'
# clean does not terminate in glibc
#
tab=$(printf '\t')
cat > build/Makefile <<EOF
clean:
${tab}rm -rf binutils-1 gcc-1 glibc-1 libstdcxx binutils-2 gcc-2 glibc-2
EOF

# script to set env vars
cat > tools/setupenv.sh <<EOF
# source this file
export TOOLCHAIN_DIR=${toolchain_dir}
export ARCHIVE_DIR=${archive_dir}
export PREFIX=${prefix}
export TARGET=${target}
export CROSS_PREFIX=$CROSS_PREFIX
export TARGET_PREFIX=$TARGET_PREFIX
export ARCH=$ARCH
export PATH=$PATH
EOF

# script for build+install sequence
cat > tools/build.sh <<EOF
#!/bin/bash
# script runs itself in TOOLCHAIN_DIR

# note: ARCHIVE_DIR..PATH aren't essential
#       given they're already expanded in tools/ helper scripts.
#       Keeping for convenience
#
export TOOLCHAIN_DIR=${toolchain_dir}
export ARCHIVE_DIR=${archive_dir}
export PREFIX=${prefix}
export TARGET=${target}
export CROSS_PREFIX=$CROSS_PREFIX
export TARGET_PREFIX=$TARGET_PREFIX
export ARCH=$ARCH
export PATH=$PATH

cd ${toolchain_dir}

################################################################
# step 1. build + install cross binutlis

echo "### 1. build + install cross binutils"

./tools/binutils-1.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 2. install linux kernel headers
#
#    - linux headers PREFIX/include
#      (also available from PREFIX/cross/TARGET/include, since
#       PREFIX/cross/TARGET -symlink-> PREFIX)
#

echo "### 2. install linux headers"

./tools/linux-headers.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 3. build + install stage1 cross gcc
#
#    - binutils in PREFIX/bin
#    - linux headers in PREFIX/include
#    - gcc in PREFIX/cross/bin
#

echo "### 3. build + install stage1 cross gcc"

./tools/gcc-1.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 4. build + install stage1 glibc

echo "### 4. build + install stage1 glibc"

./tools/glibc-1.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 5. build stage2 cross gcc
#    (using same build dir as stage1 gcc)
#
#    - binutils in PREFIX/bin
#    - linux headers in PREFIX/include
#    - gcc in PREFIX/cross/bin
#    - glibc in PREFIX/lib (also spelled PREFIX/cross/TARGET/lib)
#

echo "### step 5. build stage2 cross gcc"

./tools/gcc-1b.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 6. build + install stage2 cross glibc
#    (using same build dir as stage1 glibc)
#

echo "### step 6. build + install stage2 cross glibc"

./tools/glibc-1b.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 7. build + install libstdc++

echo "### step 7. build + install stage2 libstdc++"

./tools/libstdcxx.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 8. build final cross gcc

echo "### step 8. build final cross gcc"

./tools/gcc-1c.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# 9. verify cross toolchain can compile

echo "### step 9. verify cross toolchain can compile"

./tools/verify-1.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 10. build native binutils

echo "### step 10. build final binutils"

./tools/binutils-2.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# step 11. build final gcc

echo "### step 11. build final gcc"

./tools/gcc-2.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# 12. build final glibc

echo "### step 12. build final glibc"

./tools/glibc-2.sh

tree --filelimit 60 -L 4 ${PREFIX}

################################################################
# 13. adjust gcc specs for operation from non-standard location

echo "### step 13. capture gcc specs"

./tools/capturespecs.sh

################################################################
# 14. verify final toolchain can compile

echo "### step 14. verify final toolchain can compile"

./tools/verify-2.sh

EOF
chmod +x tools/build.sh

# script for step 1
cat > tools/binutils-1.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain/

export PATH=${PREFIX}/bin:${CROSS_PREFIX}/bin:${PATH}

pushd ${toolchain_dir}/build/binutils-1

${toolchain_dir}/src/binutils/configure --prefix=${CROSS_PREFIX} --target=${TARGET} --disable-multilib
make -j ${jobs}
make install

popd

EOF
chmod +x tools/binutils-1.sh

# script for step 2
cat > tools/linux-headers.sh <<EOF
#!/bin/bash
# should run in nix-from-csratch/toolchain/toolchain

export PATH=${PREFIX}/bin:${CROSS_PREFIX}/bin:${PATH}

pushd ${toolchain_dir}/src/linux

make ARCH=${ARCH} INSTALL_HDR_PATH=${TARGET_PREFIX} headers_install

popd

EOF
chmod +x tools/linux-headers.sh

# script for step 3
cat > tools/gcc-1.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

pushd ${toolchain_dir}/build/gcc-1

${toolchain_dir}/src/gcc/configure --prefix=${CROSS_PREFIX} \\
                                   --target=${TARGET} \\
                                   --libdir=${TARGET_PREFIX}/lib \\
                                   --libexecdir=${TARGET_PREFIX}/libexec \\
                                   --with-local-prefix=${TARGET_PREFIX} \\
                                   --with-gxx-include-dir=${TARGET_PREFIX}/include/c++ \\
                                   --enable-languages=c,c++ \\
                                   --enable-default-pie \\
                                   --disable-multilib \\
                                   --disable-libssp \\
                                   --disable-threads \\
                                   --disable-libatomic \\
                                   --disable-libffi \\
                                   --disable-libgomp \\
                                   --disable-libitm \\
                                   --disable-libquadmath \\
                                   --disable-libquadmath-support \\
                                   --disable-libsanitizer \\
                                   --disable-fixincludes \\
                                   --disable-bootstrap
make -j ${jobs} all-gcc
make install-gcc

popd

EOF
chmod +x tools/gcc-1.sh

# script for step 4
cat > tools/glibc-1.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

pushd ${toolchain_dir}/build/glibc-1

${toolchain_dir}/src/glibc/configure --prefix=${TARGET_PREFIX} \\
                                     --build=${MACHTYPE} \\
                                     --host=${TARGET} \\
                                     --target=${TARGET} \\
                                     --with-headers=${TARGET_PREFIX}/include \\
                                     --disable-multilib \\
                                     libc_cv_forced_unwind=yes

make install-bootstrap-headers=yes install-headers
make csu/subdir_lib

install csu/crt1.o csu/crti.o csu/crtn.o ${TARGET_PREFIX}/lib
${TARGET}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o ${TARGET_PREFIX}/lib/libc.so
touch ${TARGET_PREFIX}/include/gnu/stubs.h

popd

EOF
chmod +x tools/glibc-1.sh

# script for step 5
cat > tools/gcc-1b.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

pushd ${toolchain_dir}/build/gcc-1

make -j${jobs} all-target-libgcc
make install-target-libgcc

popd

EOF
chmod +x tools/gcc-1b.sh

# script for step 6
cat > tools/glibc-1b.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

pushd ${toolchain_dir}/build/glibc-1

make -j${jobs}
make install

popd

EOF
chmod +x tools/glibc-1b.sh

# script for step 7
cat > tools/libstdcxx.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

export PATH=${PREFIX}/bin:${CROSS_PREFIX}/bin:${PATH}

pushd ${toolchain_dir}/build/libstdcxx

# maybe need 14.2.0 suffix on gxx-include-dir?
${toolchain_dir}/src/gcc/libstdc++-v3/configure --prefix=${CROSS_PREFIX} \\
                                                --target=${TARGET} \\
                                                --libdir=${TARGET_PREFIX}/lib \\
                                                --libexecdir=${TARGET_PREFIX}/libexec \\
                                                --with-gxx-include-dir=${TARGET_PREFIX}/include/c++ \\
                                                --disable-multilib
make -j ${jobs}
make install

popd

EOF
chmod +x tools/libstdcxx.sh

# script for step 8
cat > tools/gcc-1c.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

pushd ${toolchain_dir}/build/gcc-1

make -j ${jobs}
make install

popd

EOF
chmod +x tools/gcc-1c.sh

# script for step 9
cat > tools/verify-1.sh <<EOF
#!/bin/bash

set -euo pipefail

source ${toolchain_dir}/tools/setupenv.sh

pushd ${toolchain_dir}/example

echo "gcc=\$(which gcc)"
echo "g++=\$(which g++)"

gcc -Wl,-rpath,${PREFIX}/lib -Wl,-dynamic-linker,${PREFIX}/lib/ld-linux-x86-64.so.2 hello-c.c -o hello-c
./hello-c || (echo "hello-c failed"; exit 1)

g++ -Wl,-rpath,${PREFIX}/lib -Wl,-dynamic-linker,${PREFIX}/lib/ld-linux-x86-64.so.2 success.cpp -o success-cxx
./success-cxx || (echo "success-cxx failed"; exit 1)

g++ -Wl,-rpath,${PREFIX}/lib -Wl,-dynamic-linker,${PREFIX}/lib/ld-linux-x86-64.so.2 hello-cxx.cpp -o hello-cxx
./hello-cxx || (echo "hello-cxx failed"; exit 1)

popd

EOF
chmod +x tools/verify-1.sh

# script for step 10
cat > tools/binutils-2.sh <<EOF
# !/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

export PATH=${PREFIX}/bin:${CROSS_PREFIX}/bin:${PATH}

pushd ${toolchain_dir}/build/binutils-2

linker=\$(find ${PREFIX}/lib -name 'ld-linux-*')
ldflags="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -Wl,-dynamic-linker,\${linker}"

LDFLAGS="\${ldflags}" ${toolchain_dir}/src/binutils/configure \\
                         --prefix=${PREFIX} \\
                         --host=${TARGET} \\
                         --enable-gold \\
                         --enable-plugins \\
                         --enable-multilib
make -j ${jobs}

# remove old linker scripts -- about to reinstall
rm -rf ${PREFIX}/lib/ldscripts

make install-strip

popd

EOF
chmod +x tools/binutils-2.sh

# script for step 11
cat > tools/gcc-2.sh <<EOF
#!/bin/bash
# should run in nix-from-scratch/toolchain/toolchain

pushd ${toolchain_dir}/build/gcc-2

linker=\$(find ${PREFIX}/lib -name 'ld-linux-*')
ldflags="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -Wl,-dynamic-linker,\${linker}"

LDFLAGS="\${ldflags}" LDFLAGS_FOR_TARGET="\${ldflags}" ${toolchain_dir}/src/gcc/configure \\
                      --prefix=${PREFIX} \\
                      --host=${TARGET} \\
                      --with-local-prefix=${PREFIX} \\
                      --enable-languages=c,c++ \\
                      --enable-default-pie \\
                      --disable-multilib \\
                      --disable-fixincludes

make BOOT_LDFLAGS="\${ldflags}" -j ${jobs}

# remove old cross includes -- about to reinstall
rm -rf ${PREFIX}/include/c++

make install

popd

EOF
chmod +x tools/gcc-2.sh

# script for step 12
cat > tools/glibc-2.sh <<EOF
#!/bin/bash

pushd ${toolchain_dir}/build/glibc-2

linker=\$(find ${PREFIX}/lib -name 'ld-linux-*')
ldflags="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -Wl,-dynamic-linker,\${linker}"

${toolchain_dir}/src/glibc/configure --prefix=${PREFIX} \\
                                     --with-headers=${PREFIX}/include \\
                                     --disable-multilib
make -j ${jobs}
make install

popd

EOF
chmod +x tools/glibc-2.sh

# script for step 13
cat > tools/capturespecs.sh <<EOF
#!/bin/bash

pushd ${toolchain_dir}/build

interpreter=\$(find ${PREFIX} -name "ld-linux-*")
filename=\$(basename \${interpreter})
dirname=\$(dirname \${interpreter})

# 1. grab specs from final gcc,
# 2. substitute \${interpreter} for linux interpreter (intsead of /lib64/ld-linux-x86-64.so.2)
# 3. insert toolchain directory $PREFIX into RUNPATH
#
# dumpspecs produces output containing something like (much reduced)
#    ...
#    ... :%{mmusl:/lib64/ld-musl-x86-64.so.1;:/lib64/ld-linux-x86-64.so.2} ...
#    ...
#    collect
#    ...
#
# we want to replace with:
#    :%{musl:....;:${toolchain_dir}/lib/ld-linux-x86-64.so.2} ...
#    ...
#    collect -rpath ${toolchain_dir}/lib
#    ...
#
# and put output where {gcc, g++} know to look for it
#
# breaking down the sed expression:
#
#       a    <- b ->    c    <---- d --->        <--- e ---> f  g
#   s | : \( [^;}:]* \) / \( \${filename} \) | : \${dirname} / \2 |
#
# a, c, f: literal characters
# b: matches default path to linux inteerpreter /lib64
# d: linux interpreter e.g. 'ld-linux-x86-64.so.2'
# e: our toolchain directory pathname, e.g. $HOME/nxfs-toolchain/lib
# g: linux interpreter matched in d
#
${PREFIX}/bin/gcc -dumpspecs | sed "{
  s|:\([^;}:]*\)/\(\${filename}\)|:\${dirname}/\2|g
  s|collect2|collect2 -rpath \${dirname}|
}" > ${PREFIX}/lib/gcc/${TARGET}/specs

EOF
chmod +x tools/capturespecs.sh

# script for step 14
cat > tools/verify-2.sh <<EOF
#!/bin/bash

set -euo pipefail

source ${toolchain_dir}/tools/setupenv.sh

pushd ${toolchain_dir}/example

echo "gcc=\$(which gcc)"
echo "g++=\$(which g++)"

gcc hello-c.c -o hello-c2
./hello-c2 || (echo "hello-c2 failed"; exit 1)

g++ success.cpp -o success-cxx2
./success-cxx2 || (echo "success-cxx2 failed"; exit 1)

g++ hello-cxx.cpp -o hello-cxx2
./hello-cxx2 || (echo "hello-cxx2 failed"; exit 1)

popd

EOF
chmod +x tools/verify-2.sh

################################################################A
# step 0b. Prepare destination symlinks

if [[ -e ${PREFIX} ]]; then
    echo "error: ${self_name}: expected path PREFIX to not exist yet (correct build wouuld have to clobber anyway)"
    exit 1
fi

mkdir -p ${CROSS_PREFIX}
ln -snf .. ${CROSS_PREFIX}/${TARGET}

mkdir -p ${TARGET_PREFIX}/lib
ln -snf lib ${TARGET_PREFIX}/lib64

echo "stage 0 toolchain dir"
tree --filelimit=10 ${PREFIX} || true

################################################################
# step 0c. Scaffold build directories

mkdir -p build/binutils-1
mkdir -p build/gcc-1
mkdir -p build/glibc-1
mkdir -p build/libstdcxx
mkdir -p build/binutils-2
mkdir -p build/gcc-2
mkdir -p build/glibc-2
