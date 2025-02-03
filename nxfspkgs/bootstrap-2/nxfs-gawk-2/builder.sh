#!/bin/bash

set -e
#set -x

echo "gcc_wrapaper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "findutils=${findutils}";
echo "diffutils=${diffutils}";
echo "sysroot=${sysroot}"
echo "bash=${bash}"
echo "src=${src}"
echo "nxfs_system=${nxfs_system}";
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

# 1. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 2. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 3. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 4. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

ls -l ${toolchain}/x86_64-pc-linux-gnu/bin

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}
mkdir ${source}

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))
chmod -R +w ${src2}

# 2. substitute nix-store path-to-bash for /bin/sh.
#
#
bash_program=${bash}/bin/bash
# skipping:
#   .m4 and .in files (assume they trigger re-running autoconf)
#   test/ files
#
sed -i -e "s:/bin/sh:${bash_program}:g" ${src2}/configure ${src2}/build-aux/*

# The file io.c contains sveral calls like
#   execl("/bin/sh", "sh", "-c", command, NULL)
# rewrite these to
#   execl("/path/to/nix/store/bash/bin/bash", "bash", "c", command, NULL)
#
sed -i -e 's:"/bin/sh", "sh":"'${bash_program}'", "bash":' ${src2}/io.c

# insert decl
#    statc int nxfs_system(const char* line);
# near the top of builtin.c
#
sed -i -e '/^static size_t mbc_byte_count/ i\
static int nxfs_system(const char* line);\
' ${src2}/builtin.c

nxfs_system_src=${nxfs_system}/src/nxfs_system.c

# use nxfs_system() instead of glibc system() to implement gawk's system() builtin
#
sed -i -e 's:status = system(cmd):status = nxfs_system(cmd):' ${src2}/builtin.c

# add definition of nxfs_system() to builtin.c
#
cat ${nxfs_system_src} >> ${src2}/builtin.c

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

# inspect shebang
head -5 ${src2}/configure

(cd ${builddir} && ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} CFLAGS="-I${sysroot}/usr/include" LDFLAGS="-Wl,-enable-new-dtags" SHELL=${CONFIG_SHELL})

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

(cd ${src2} && (tar cvf - . | tar xf - -C ${source}))
