echo "toolchain_wrapper=${toolchain_wrapper}"
echo "toolchain=${toolchain}"

set -e
set -x

PATH=${sed}/bin
PATH=${PATH}:${coreutils}/bin
PATH=${PATH}:${toolchain_wrapper}/bin
PATH=${PATH}:${toolchain}/bin
PATH=${PATH}:${toolchain}/x86_64-pc-linux-gnu/debug-root/usr/bin
PATH=${PATH}:${bash}/bin
export PATH

mkdir -p ${out}/src
mkdir -p ${out}/bin
mkdir -p ${out}/log

dest=${out}/src/popen.c
cp ${src} ${dest}

bash_program=${bash}/bin/bash
sort_program=${coreutils}/bin/sort

sed -i -e "s:@bash_path@:${bash_program}:" ${dest}
sed -i -e "s:@sort_program@:${sort_program}:" ${dest}

nxfs-gcc -o ${out}/bin/popen ${dest}

cd ${out}

# strace -f ${out}/bin/popen > ${out}/log/popen.out
${out}/bin/popen > ${out}/log/popen.out
