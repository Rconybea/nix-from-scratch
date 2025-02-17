#! /bin/bash

# See also
#  https://www.linuxfromscratch.org/lfs/view/12.2/chapter05/glibc.html

echo "src=${src}"
echo "patchelf=${patchelf}"
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
echo "bash=${bash}"
echo "lc_all_sort=${lc_all_sort}"

echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -e
set -x


export PATH=${bash}/bin:${PATH}
export PATH=${patch}/bin:${PATH}
export PATH=${coreutils}/bin:${PATH}
export PATH=${sed}/bin:${PATH}
export PATH=${grep}/bin:${PATH}
export PATH=${gawk}/bin:${PATH}
export PATH=${tar}/bin:${PATH}
export PATH=${gnumake}/bin:${PATH}
export PATH=${findutils}/bin:${PATH}
export PATH=${diffutils}/bin:${PATH}
export PATH=${gzip}/bin:${PATH}
export PATH=${sysroot}/sbin:${PATH}
export PATH=${toolchain}/x86_64-pc-linux-gnu/debug-root/usr/bin:${PATH}
export PATH=${toolchain}/x86_64-pc-linux-gnu/bin:${PATH}
export PATH=${toolchain}/bin:${PATH}
export PATH=${gcc_wrapper}/bin:${PATH}
export PATH=${bison}/bin:${PATH}
export PATH=${texinfo}/bin:${PATH}
export PATH=${python}/bin:${PATH}
export PATH=${gperf}/bin:${PATH}
export PATH=${patchelf}/bin:${PATH}
export PATH=${lc_all_sort}/bin:${PATH}

mkdir ${out}
mkdir ${source}

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

bash_program=${bash}/bin/bash
python_program=${python}/bin/python3
sort_program=${coreutils}/bin/sort

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

sed -i -e "s:/bin/bash:${bash_program}:" ./Makefile
#sed -i -e "s:/bin/sh:${bash_program}:" ./lib/oldiopopen.c
sed -i -e "s:/bin/sh:${bash_program}:" ./sysdeps/generic/paths.h
sed -i -e "s:/bin/sh:${bash_program}:" ./sysdeps/unix/sysv/linux/paths.h

sed -i -e '/^define SHELL_NAME/ s:"sh":"bash":' -e "s:/bin/sh:${bash_program}:" ./sysdeps/posix/system.c

sed -i -e "s:/bin/sh:${bash_program}:" ./libio/oldiopopen.c
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

# note: the 'locale' program does not honor this.  However setlocale() does.
export LOCPATH=${locale_archive}/lib/locale
export CONFIG_SHELL="${bash_program}"

pushd ${builddir}

echo "rootsbindir=${out}/sbin" > configparms

find ${src2} -name '*.awk' | xargs --replace=xx sed -i -e 's:LC_ALL=C sort -u:lc-all-sort-wrapper -u:' xx
find ${src2} -name '*.awk' | xargs --replace=xx sed -i -e 's:sort -t:'${sort_program}' -t:' -e 's:sort -u:'${sort_program}' -u:' xx
(find ${src2} -name '*.awk' | xargs --replace=xx grep sort xx ) || true

# headers from toolchain
#/usr/bin/strace -f bash ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --enable-kernel=4.19 --with-headers=${sysroot}/usr/include --disable-nscd libc_cv_slibdir=${out}/lib CC=nxfs-gcc CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
#
# libc_cv_complocaledir: this sets compiled-in default locale directory.
# We need something that comes from the nix store so that basic locale queries
# work from within isolated nix builds
#
bash ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} --enable-kernel=4.19 --with-headers=${sysroot}/usr/include --disable-nscd libc_cv_complocaledir=${locale_archive}/lib/locale libc_cv_slibdir=${out}/lib CC=nxfs-gcc CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"

# looks like
#   make Versions.v.i
# fails in nix-build because of stray reference to /bin/sh
# we understand that the configure step does write/modify files in ${src2}
#
(cd ${src2} && (grep -n -R '/bin/sh' . | grep -v nix/store))

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
export NXFS_SYSROOT_DIR=${out}

#(cd ${builddir} && make help SHELL=${CONFIG_SHELL})
#/usr/bin/strace -f -e trace=openat make all SHELL=${CONFIG_SHELL}
export SHELL=${CONFIG_SHELL}

# Some things that can make build fail in chrooted build:
# 1. gnumake $(shell ...) invoking /bin/sh
#    (instead of bash from nxfs-bash-2)
#    Fixed by building nxfs-gnumake-2 after nxfs-bash-2,
#    + redirecting some /bin/sh references to nix-store
# 2. gawk system() builtin invoking unaltered system() from glibc
#    (which tries to invoke /bin/sh, as mandated by POSIX).
#    Fix by writing snowflake version of system(), and splicing
#    into nxfs-gawk-2.  See nxfs-system-2

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

patchelf --remove-rpath ${out}/lib/libc.so.6

(cd ${src2} && (tar cf - . | tar xf - -C ${source}))
