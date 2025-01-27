#! /bin/bash

# See also
#  https://www.linuxfromscratch.org/lfs/view/12.2/chapter05/glibc.html

echo "src=${src}"
echo "python=${python}"
echo "bison=${bison}"
echo "patch=${patch}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "diffutils=${diffutils}"
echo "findutils=${findutils}"
echo "gzip=${gzip}"
echo "coreutils=${coreutils}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "texinfo=${texinfo}";
echo "coreutils=${coreutils}"
echo "sysroot=${sysroot}"
#echo "mkdir=${mkdir}"
#echo "head=${head}"
echo "bash=${bash}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -e
set -x

export PATH="${gperf}/bin:${python}/bin:${texinfo}/bin:${bison}/bin:${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${gzip}/bin:${diffutils}/bin:${findutils}/bin:${gnumake}/bin:${tar}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${coreutils}/bin:${patch}/bin:${bash}/bin"

#src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

#mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}
mkdir ${source}

src2=${source}

bash_program=${bash}/bin/bash
python_program=${python}/bin/python3

# 1. copy source tree to temporary directory
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

chmod -R +w ${src2}

pushd ${src2}

sed -i -e 's:\$(localstatedir)/db:\$(localstatedir)/lib/nss_db:' ./Makeconfig
sed -i -e 's:/var/db/nscd/:/var/cache/nscd/:' ./nscd/nscd.h
sed -i -e 's:VAR_DB = /var/db:VARDB = /var/lib/nss_db:' ./nss/db-Makefile
sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/generic/paths.h
sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/unix/sysv/linux/paths.h

#(cd ${src2} && sed -i -e ":/bin/sh:${bash_program}:" ./libio/oldioopen.c)
sed -i -e "s:/bin/bash:${bash_program}:" ./Makefile
#sed -i -e "s:/bin/sh:${bash_program}:" ./lib/oldiopopen.c
sed -i -e "s:/bin/sh:${bash_program}:" ./sysdeps/generic/paths.h
sed -i -e "s:/bin/sh:${bash_program}:" ./sysdeps/unix/sysv/linux/paths.h
sed -i -e "s:/bin/sh:${bash_program}:" ./sysdeps/posix/system.c
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/build-many-glibcs.py
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/cross-test-ssh.sh
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/config.guess
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/dso-ordering-test.py
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-vfork3.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/test-errno.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-fexecve.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-spawn3.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-execveat.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/bug-regex9.c
sed -i -e "s:/bin/sh:${bash_program}:" ./elf/tst-valgrind-smoke.sh
sed -i -e "s:/bin/sh:${bash_program}:" ./debug/xtrace.sh

find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/sh:#!'${bash_program}':' xx
find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/bash:#!'${bash_program}':' xx
find . -type f | xargs --replace=xx sed -i -e '1s:#! */usr/bin/python3:#!'${python_program}':' xx

# patch: fix bad function signature on locfile_hash() in locfile-kw.h, and charmap_hash() in charmap-kw.h
#
sed -i -e '/^locfile_hash/s:register unsigned int len:register size_t len:' locale/programs/locfile-kw.h
sed -i -e '/^charmap_hash/s:register unsigned int len:register size_t len:' locale/programs/charmap-kw.h

set +e

(grep -n -R '/bin/sh' . | grep -v nix/store)
(grep -n -R '/bin/bash' . | grep -v nix/store)

set -e

popd

export CONFIG_SHELL="${bash_program}"

pushd ${builddir}

echo "rootsbindir=${out}/sbin" > configparms

# headers from toolchain
#/usr/bin/strace -f bash ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --enable-kernel=4.19 --with-headers=${sysroot}/usr/include --disable-nscd libc_cv_slibdir=${out}/lib CC=nxfs-gcc CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
bash ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --enable-kernel=4.19 --with-headers=${sysroot}/usr/include --disable-nscd libc_cv_slibdir=${out}/lib CC=nxfs-gcc CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"

# The compiler (nxfs-gcc, from ../nxfs-gcc-wrapper-2), that we passed to configure,
# automatically makes two link-time changes when it builds a library/executable
# 1. sets ELF interpreter to specific dynamic linker
# 2. sets RPATH/RUNPATH to pickup libc
# both coming from nix-from-scratch/nxfspkgs/bootstrap-1/nxfs-sysroot-1.
#
# We need that behavior above, to convince configure that compiler builds working executables.
# However its counterproductive when we build libc, and executables that depend on it.
#
# Use the backdoor environment variable NXFS_SYSROOT_DIR to get nxfs-gcc to use
# the {ld-linux-x86-64.so.2, glibc} that we're building here.
#
export NXFS_SYSROOT_DIR=${out}

#(cd ${builddir} && make help SHELL=${CONFIG_SHELL})
#/usr/bin/strace -f make all SHELL=${CONFIG_SHELL}
make all SHELL=${CONFIG_SHELL}

# Final cleanup -- nxfs-gcc will create an RPATH entry in
#   {libc.so.6, ld-linux-x86-64.so.2}
# In other libs/exes the inserted RPATH tells them how to find libc;
# we don't want that in libc itself,  and RPATH is unnecessary in the
# the dynamic linker
#
patchelf --remove-rpath libc.so.6
patchelf --remove-rpath elf/ld-linux-x86-64.so.2

make install SHELL=${CONFIG_SHELL}
