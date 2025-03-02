#! /bin/bash

echo "which=${which}"
echo "gawktestscript=${gawktestscript}"

set -e
set -x

export PATH="${which}/bin:${gawk}/bin:${bash}/bin:${coreutils}/bin"

builddir=${TMPDIR}

mkdir -p ${out}

cd ${builddir}

gawk -f ${gawktestscript} < /dev/null > ${out}/gawk.out
touch foo
gawk -f ${gawktestscript} < /dev/null >> ${out}/gawk.out

echo "done" > ${out}/done

(cd ${out} && ln -s $(which gawk))
