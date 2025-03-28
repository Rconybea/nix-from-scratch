#!/bin/bash

echo
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "nxfs_system_src=${nxfs_system_src}"

set -e
set -x

export PATH="${coreutils}/bin:${bash}/bin"

bash_program=${bash}/bin/bash

mkdir -p ${out}/src

cp ${nxfs_system_src} ${out}/src/nxfs_system.c
cp ${nxfs_popen_src} ${out}/src/nxfs_popen.c
