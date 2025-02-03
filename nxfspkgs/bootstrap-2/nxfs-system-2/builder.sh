#!/bin/bash

set -e

echo
echo "coreutils=${coreutils}"
echo "sed=${sed}"
echo "bash=${bash}"
echo "nxfs_system_src=${nxfs_system_src}"

export PATH="${coreutils}/bin:${sed}/bin:${bash}/bin"

bash_program=${bash}/bin/bash

mkdir -p ${out}/src

cp ${nxfs_system_src} ${out}/src/nxfs_system.c
cp ${nxfs_popen_src} ${out}/src/nxfs_popen.c

sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'${bash_program}':' ${out}/src/nxfs_system.c
sed -i -e '/^#define SHELL_PATH/s:@bash_path@:'${bash_program}':' ${out}/src/nxfs_popen.c
