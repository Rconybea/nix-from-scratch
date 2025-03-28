#! /bin/bash
#
# Required environment variables:
#   bash
#   binutils
#   glibc
#   ld_wrapper_script
#   buildInputs
#   TMPDIR
#   out

set -euo pipefail

PATH=
for pkg in ${buildInputs}; do
    if [[ -d ${pkg} ]]; then
        if [[ -n ${PATH} ]]; then
            PATH+=":"
        fi
        PATH+=${pkg}/bin
    fi
done

echo "PATH=$PATH"

bash_program=${bash}/bin/bash

builddir=${TMPDIR}

unwrapped_ld=${binutils}/bin/ld

mkdir -p ${builddir}/bin
mkdir -p ${out}/bin

# prepare ld-wrapper script from template
tmp=${builddir}/bin/ld
cp ${ld_wrapper_script} ${tmp}
sed -i -e s:@bash@:${bash_program}: ${tmp}
sed -i -e s:@unwrapped_ld@:${unwrapped_ld}: ${tmp}
sed -i -e s:@glibc@:${glibc}: ${tmp}
chmod +x ${tmp}
# install ld-wrapper script to output
cp ${tmp} ${out}/bin
