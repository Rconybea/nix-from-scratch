#!/bin/bash

echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "sed=${sed}"
echo "which_script=${which_script}"

set -e
set -x

export PATH="${sed}/bin:${bash}/bin:${coreutils}/bin"

bash_program=${bash}/bin/bash

mkdir -p ${out}/bin

which_script_tmp=${TMPDIR}/$(basename ${which_script})

cp ${which_script} ${which_script_tmp}

sed -i -e '1s:/bin/sh:'${bash_program}':' ${which_script_tmp}

cp ${which_script_tmp} ${out}/bin/which
