#!/bin/bash

echo
echo "sed=${sed}"
echo "bash=${bash}"
echo "gawk=${gawk}"
echo "execve_preload=${execve_preload}"
echo "src=${src}"
echo

set -e
set -x

export PATH="${sed}/bin:${bash}/bin:${coreutils}/bin"

mkdir -p ${out}/bin

bash_program=${bash}/bin/bash
gawk_program=${gawk}/bin/gawk

cp ${src} ${out}/bin/gawk

sed -i -e 's:@bash_program@:'${bash_program}':' ${out}/bin/gawk
sed -i -e 's:@execve_preload@:'${execve_preload}':' ${out}/bin/gawk
sed -i -e 's:@gawk_program@:'${gawk_program}':' ${out}/bin/gawk
