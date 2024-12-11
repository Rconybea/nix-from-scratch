# script to intercept calls to ${gcc},
# and inject additional arguments
#

echo "toolchain=${toolchain}"
echo "sed=${sed}"
echo "coreutils=${coreutils}"
echo "sysroot=${sysroot}"
echo "bash=${bash}"

echo "gcc_wrapper_script=${gcc_wrapper_script}"
echo "gxx_wrapper_script=${gxx_wrapper_script}"

echo "gcc=${gcc}";
echo "gxx=${gxx}";

builddir=${TMPDIR}

export PATH="${toolchain}/bin:${sed}/bin:${coreutils}/bin:${bash}/bin"

# path/to/nix/store/{hash}-x86_64-pc-linux-gnu-gcc
unwrapped_gcc=${gcc}
# path/to/nix/store/{hash}-x86_64-pc-linux-gnu-gxx
unwrapped_gxx=${gxx}

mkdir -p ${builddir}/bin

# x86_64-pc-linux-gnu-gcc
gcc_basename=$(basename ${gcc})
# x86_64-pc-linux-gnu-gxx
gxx_basename=$(basename ${gxx})

mkdir -p ${out}/bin

# prepare gcc-wrapper script from template
tmp=${builddir}/bin/${gcc_basename}
cp ${gcc_wrapper_script} ${tmp}
sed -i -e s:@unwrapped_gcc@:${unwrapped_gcc}: ${tmp}
sed -i -e s:@sysroot@:${sysroot}: ${tmp}
chmod +x ${tmp}
cp ${tmp} ${out}/bin

# prepare gxx-wrapper script from template
tmp=${builddir}/bin/${gxx_basename}
cp ${gxx_wrapper_script} ${tmp}
sed -i -e s:@unwrapped_gxx@:${unwrapped_gxx}: ${tmp}
sed -i -e s:@sysroot@:${sysroot}: ${tmp}
chmod +x ${tmp}
cp ${tmp} ${out}/bin
