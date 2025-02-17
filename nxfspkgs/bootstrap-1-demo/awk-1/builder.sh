PATH=${gawk}/bin:${sed}/bin:${coreutils}/bin:${PATH}

gawk_program=${gawk}/bin/gawk
mkdir ${out}

cp ${script} ${out}/script.awk
sed -i -e 's:/usr/bin/gawk:'${gawk_program}':' ${out}/script.awk
#gawk --field-separator=';' '{print $1;}' ${input} > ${out}/output1.txt

${out}/script.awk ${input} > ${out}/output1.txt
