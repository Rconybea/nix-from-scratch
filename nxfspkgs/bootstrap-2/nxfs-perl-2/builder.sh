#!/bin/bash

set -euo pipefail
set -x

echo "gcc_wrapper=${gcc_wrapper}"
echo "toolchain=${toolchain}"
echo "gnumake=${gnumake}"
echo "gawk=${gawk}"
echo "grep=${grep}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "findutils=${findutils}"
echo "diffutils=${diffutils}"
echo "bash=${bash}"
echo "src=${src}"
echo "target_tuple=${target_tuple}"
echo "TMPDIR=${TMPDIR}"

export PATH="${gcc_wrapper}/bin:${toolchain}/bin:${gnumake}/bin:${gawk}/bin:${grep}/bin:${sed}/bin:${tar}/bin:${coreutils}/bin:${findutils}/bin:${diffutils}/bin:${bash}/bin"

src2=${TMPDIR}/src2

# perl builds in source tree

builddir=${src2}

mkdir -p ${src2}

mkdir ${out}

# 1. copy source tree to temporary directory,
#
(cd ${src} && (tar cf - . | tar xf - -C ${src2}))

# 2. since we're building in source tree,
#    will need to be able to write there
#
chmod -R +w ${src2}

bash_program=${bash}/bin/bash

# ${src}/configure honors CONFIG_SHELL
export CONFIG_SHELL="${bash_program}"

# 1.
# we shouldn't need special compiler/linker instructions,
# since stage-1 toolchain "knows where it lives"
#
# 2.
# do need to give --host and --build arguments to configure,
# since we're using a cross compiler.

version_major_minor=5.40
perlout=${out}/lib/perl5/${version_major_minor}

cd ${builddir}

# -d: use defaults
# -e: stop questions after config.sh
# -s: silent mode
#
# removing -Dcpp=nxfs-gcc (why did we need this)
#
sh Configure -de -Dperl_lc_all_uses_name_value_pairs=define -Dcc=${gcc_wrapper}/bin/nxfs-gcc -Dcppflags="-I${toolchain}/include" -Dccflags="-I${toolchain}/include -DNO_LOCALE -v" -Dldflags="-Wl,-enable-new-dtags" -Dprefix=${out} -Dsysroot=${toolchain} -Dvendorprefix=${out} -Duseshrplib -Dprivlib=${perlout}/core_perl -Darchlib=${perlout}/core_perl -Dsitelib=${perlout}/site_perl -Dsitearch=${perlout}/site_perl -Dvendorlib=${perlout}/vendor_perl -Dvendorarch=${perlout}/vendor_perl

make SHELL=${CONFIG_SHELL}

make install SHELL=${CONFIG_SHELL}

# ----------------------------------------------------------------
# verify executable runs

${out}/bin/perl --version
