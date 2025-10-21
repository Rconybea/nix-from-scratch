# script to intercept calls to ${gcc},
# and inject additional arguments
#

set -euo pipefail

echo "sed=${sed}"
echo "coreutils=${coreutils}"
echo "glibc=${glibc}"
echo "bash=${bash}"

echo "gcc_wrapper_script=${gcc_wrapper_script}"
echo "gxx_wrapper_script=${gxx_wrapper_script}"

echo "gcc=${gcc}";

builddir=${TMPDIR}

set -x

export PATH="${gcc}/bin:${glibc}/bin:${sed}/bin:${coreutils}/bin:${bash}/bin"

unwrapped_gcc=${gcc}/bin/gcc
unwrapped_gxx=${gcc}/bin/g++

mkdir -p ${builddir}/bin

# x86_64-pc-linux-gnu-gcc
gcc_basename=gcc
# x86_64-pc-linux-gnu-gxx
gxx_basename=g++

mkdir -p ${out}/bin
mkdir -p ${out}/nix-support

# also provide secondary names
#   nxfs-gcc
#   nxfs-g++
#
# Might be helpful when diagnosing certain problems during bootstrap,
# to use a name that's distinct from the destination binary's name,
# so we can know which one's being invoked.

# prepare gcc-wrapper script from template
tmp=${builddir}/bin/${gcc_basename}
cp ${gcc_wrapper_script} ${tmp}
sed -i -e s:@bash@:${bash}/bin/bash: ${tmp}
sed -i -e s:@unwrapped_gcc@:${unwrapped_gcc}: ${tmp}
sed -i -e s:@gcc@:${gcc}: ${tmp}
sed -i -e s:@bintools@:${bintools}: ${tmp}
sed -i -e s:@glibc@:${glibc}: ${tmp}
chmod +x ${tmp}
cp ${tmp} ${out}/bin/
cp ${tmp} ${out}/bin/nxfs-gcc

# prepare gxx-wrapper script from template
tmp=${builddir}/bin/${gxx_basename}
cp ${gxx_wrapper_script} ${tmp}
sed -i -e s:@bash@:${bash}/bin/bash: ${tmp}
sed -i -e s:@unwrapped_gxx@:${unwrapped_gxx}: ${tmp}
sed -i -e s:@gcc@:${gcc}: ${tmp}
sed -i -e s:@bintools@:${bintools}: ${tmp}
sed -i -e s:@glibc@:${glibc}: ${tmp}
sed -i -e s:@target_tuple@:${target_tuple}: ${tmp}
sed -i -e s:@cxx_version@:${cxx_version}: ${tmp}
chmod +x ${tmp}
cp ${tmp} ${out}/bin/
cp ${tmp} ${out}/bin/nxfs-g++

cp ${setup_hook} ${out}/nix-support/setup-hook

# verify gcc wrappers run

${out}/bin/nxfs-gcc -v
${out}/bin/nxfs-g++ -v
