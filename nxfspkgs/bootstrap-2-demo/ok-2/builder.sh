echo "gcc_wrapper=${gcc_wrapper}"
echo "gcc=${gcc}"
echo "binutils=${binutils}"
echo "coreutils=${coreutils}"
echo "src=${src}"

PATH=${gcc_wrapper}/bin:${gcc}/bin:${gawk}/bin:${sed}/bin:${binutils}/bin:${coreutils}/bin

mkdir ${out}
mkdir ${out}/bin

cd ${TMPDIR}

nxfs-gcc ${src} -o ${out}/bin/test

