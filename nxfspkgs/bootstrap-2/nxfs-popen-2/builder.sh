#!/bin/bash

echo
echo "coreutils=${coreutils}"
echo "popen_template=${popen_template}"
echo "sed=${sed}"
echo "bash=${bash}"

set -e
set -x

export PATH="${coreutils}/bin:${sed}/bin:${bash}/bin"

bash_program=${bash}/bin/bash

mkdir -p ${out}/src

cp ${popen_template}/src/nxfs_system.c ${out}/src/nxfs_system.c
cp ${popen_template}/src/nxfs_popen.c ${out}/src/nxfs_popen.c

sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'${bash_program}':' ${out}/src/nxfs_system.c
sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'${bash_program}':' ${out}/src/nxfs_popen.c
