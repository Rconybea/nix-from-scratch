#!/bin/bash

set -euo pipefail

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
echo "bash=${bash}"
echo "src=${src}"
echo "TMPDIR=${TMPDIR}"

set -x

export PATH="${autoconf}/bin:${perl}/bin:${m4}/bin:${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2
builddir=${TMPDIR}/build

mkdir -p ${src2}
mkdir -p ${builddir}

mkdir ${out}

bash_program=${bash}/bin/bash
perl_program=${perl}/bin/perl

# NOTE: problem encountered in nix build:
#
# 1. nix build triggers make rule to regenerate src/t/testsuite-part.am
# 2. make rule looks buggy afacit:  it assumes directory $(pwd)/t exists,
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

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

(cd ${builddir} && bash ${src}/configure --prefix=${out} CC="nxfs-gcc" CXX="nxfs-g++" LDFLAGS="-Wl,-enable-new-dtags")

(cd ${builddir} && sed -i -e 's:#! */bin/sh:#! '${bash_program}':' ./pre-inst-env)

(cd ${builddir} && make SHELL=${CONFIG_SHELL})

(cd ${builddir} && make install SHELL=${CONFIG_SHELL})

# verify executable runs
${out}/bin/automake --version
