PATH=${gawk}/bin:${sed}/bin:${coreutils}/bin:${toolchain}/x86_64-pc-linux-gnu/debug-root/usr/bin:${PATH}

gawk_program=${gawk}/bin/gawk
sort_program=${coreutils}/bin/sort

mkdir ${out}

cp ${script} ${out}/script.awk
sed -i -e 's:/usr/bin/gawk:'${gawk_program}':' ${out}/script.awk
sed -i -e 's:@sort_program@:'${sort_program}':' ${out}/script.awk

echo "script.awk:"
cat ${out}/script.awk

${out}/script.awk ${input} > ${out}/output1.txt
