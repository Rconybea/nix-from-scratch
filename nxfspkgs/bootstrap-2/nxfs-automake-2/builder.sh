#!/bin/bash

set -e

echo "findutils=${findutils}"
echo "autoconf=${autoconf}"
echo "m4=${m4}"
echo "perl=${perl}"
echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "sysroot=${sysroot}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

set -x

# 1. ${gcc_wrapper}/bin/x86_64-pc-linux-gnu-{gcc,g++} builds viable executables.
# 2. ${toolchain}/bin/x86_64-pc-linux-gnu-gcc can build executables,
#    but they won't run unless we pass special linker flags
# 3. ${toolchain}/bin                     has x86_64-pc-linux-gnu-ar
# 4. ${toolchain}/x86_64-pc-linux-gnu/bin has ar  <- autotools looks for this
#
export PATH="${autoconf}/bin:${perl}/bin:${m4}/bin:${gcc_wrapper}/bin:${toolchain}/bin:${toolchain}/x86_64-pc-linux-gnu/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

#src2=${src}
src2=${TMPDIR}/src2
builddir=${TMPDIR}/build
#builddir=${src2}

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash
perl_program=${perl}/bin/perl

# NOTE: problem encountered in nix build:
#
# 1. nix build triggers make rule to regenerate src/t/testsuite-part.am
# 2. make rule lookes buggy afacit:  it assumes can directory $(pwd)/t exists,
#    to hold .tmp file
#    (note that if you attempt in-source-tree build, this requirement probably
#    gets satisfied accidentally
#
#    $(srcdir)/t/testsuite-part.am:
#      $(AM_V_at)rm -f t/testsuite-part.tmp $@
#      echo "hi roly: pwd [$$(pwd)]"
#      /usr/bin/strace -f $(AM_V_GEN)$(PERL) $(srcdir)/gen-testsuite-part \
#        --srcdir $(srcdir) > t/testsuite-part.tmp
#      $(AM_V_at)chmod a-w t/testsuite-part.tmp
#      $(AM_V_at)mv -f t/testsuite-part.tmp $@
#
# 3. try to finesse by creating the directory..

mkdir -p ${builddir}/t

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

chmod -R +w ${src2}

# patching shebangs seems to make everything go sideways.  nixpkgs does not either, to allow invoking nix-owned automake from outside nix
#
#(cd ${src2} &&  find . -type f | grep -v '*\.am$' | xargs --replace=xx sed -i -e 's:#! */bin/sh:#! '${bash_program}':' -e 's:#! */usr/bin/env perl:#! '${perl_program}':' xx)
#(cd ${src2} && sed -i -e 's:/bin/sh:'${bash_program}':' GNUmakefile)
#(cd ${src2} && sed -i -e 's:/bin/sh:'${bash_program}':' bootstrap)
#(cd ${src2} && sed -i -e 's:/bin/sh:'${bash_program}':' lib/config.guess)
#(cd ${src2} && sed -i -e 's:/bin/sh:'${bash_program}':' t/ax/am-test-lib.sh)
#(cd ${src2} && sed -i -e 's:/bin/sh:'${bash_program}':' t/missing3.sh)

# Must skip:
#   .m4 and .in files (assume they trigger re-running autoconf)
#   test/ files
#
#sed -i -e "s:/bin/sh:${bash_program}:g" ${src2}/configure #${src2}/build-aux/*

# ${src2}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

(cd ${builddir} && bash ${src2}/configure --prefix=${out} --host=${target_tuple} --build=${target_tuple} CC="nxfs-gcc" CXX="nxfs-g++" CFLAGS="-I${sysroot}/usr/include" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && sed -i -e 's:#! */bin/sh:#! '${bash_program}':' ./pre-inst-env)

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})
