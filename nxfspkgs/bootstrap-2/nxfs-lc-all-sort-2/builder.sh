# script to intercept calls to ${gcc},
# and inject additional arguments
#

echo "sed=${sed}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"

echo "lc_all_sort_script=${lc_all_sort_script}"

builddir=${TMPDIR}

set -e
set -x

export PATH="${sed}/bin:${coreutils}/bin:${bash}/bin"

sort_program=${coreutils}/bin/sort

mkdir -p ${builddir}/bin
mkdir -p ${out}/bin

# prepare lc-all-sort script from template
tmp=${builddir}/bin/lc-all-sort-wrapper
cp ${lc_all_sort_script} ${tmp}
sed -i -e s:@bash@:${bash}/bin/bash: ${tmp}
sed -i -e s:@coreutils@:${coreutils}: ${tmp}
sed -i -e s:@sort_program@:${sort_program}: ${tmp}
chmod +x ${tmp}
cp ${tmp} ${out}/bin

