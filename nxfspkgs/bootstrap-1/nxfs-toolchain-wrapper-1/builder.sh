# script to intercept calls to ${gcc},
# and inject additional arguments
#

set -euo pipefail

echo "toolchain=${toolchain}"
echo "sed=${sed}"
echo "coreutils=${coreutils}"
echo "toolchain=${toolchain}"
echo "bash=${bash}"

echo "gcc_wrapper_script=${gcc_wrapper_script}"
echo "gxx_wrapper_script=${gxx_wrapper_script}"

echo "gcc=${gcc}";
echo "gxx=${gxx}";
echo "gcc_specs=${gcc_specs}"

builddir=${TMPDIR}

export PATH="${toolchain}/bin:${sed}/bin:${coreutils}/bin:${bash}/bin"

# path/to/nix/store/gcc (or say x86_64-pc-linux-gnu-gcc)
unwrapped_gcc=${gcc}
# path/to/nix/store/g++ (or say x86_64-pc-linux-gnu-g++)
unwrapped_gxx=${gxx}

dynamic_linker=$(readlink -f ${toolchain}/bin/ld.so)

mkdir -p ${builddir}/bin

# x86_64-pc-linux-gnu-gcc
gcc_basename=$(basename ${gcc})
# x86_64-pc-linux-gnu-gxx
gxx_basename=$(basename ${gxx})

mkdir -p ${out}/bin

sysroot=${toolchain}

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
sed -i -e s:@bintools@:${toolchain}: ${tmp}
sed -i -e s:@gcc_specs@:${gcc_specs}: ${tmp}
sed -i -e s:@bash@:${bash}/bin/bash: ${tmp}
sed -i -e s:@unwrapped_gcc@:${unwrapped_gcc}: ${tmp}
sed -i -e s:@sysroot@:${sysroot}: ${tmp}
sed -i -e s:@dynamic_linker@:${dynamic_linker}: ${tmp}
chmod +x ${tmp}
cp ${tmp} ${out}/bin
cp ${tmp} ${out}/bin/nxfs-gcc

# prepare gxx-wrapper script from template
tmp=${builddir}/bin/${gxx_basename}
cp ${gxx_wrapper_script} ${tmp}
sed -i -e s:@bintools@:${toolchain}: ${tmp}
sed -i -e s:@gcc_specs@:${gcc_specs}: ${tmp}
sed -i -e s:@bash@:${bash}/bin/bash: ${tmp}
sed -i -e s:@unwrapped_gxx@:${unwrapped_gxx}: ${tmp}
sed -i -e s:@sysroot@:${sysroot}: ${tmp}
sed -i -e s:@dynamic_linker@:${dynamic_linker}: ${tmp}
chmod +x ${tmp}
cp ${tmp} ${out}/bin
cp ${tmp} ${out}/bin/nxfs-g++

# verify gcc wrappers run

${out}/bin/nxfs-gcc -v
${out}/bin/nxfs-g++ -v
