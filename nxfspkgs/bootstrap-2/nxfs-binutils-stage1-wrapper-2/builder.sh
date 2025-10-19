#! /bin/bash
#
# Required environment variables:
#   bash
#   binutils
#   glibc
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

bash_program=${bash}/bin/bash

builddir=${TMPDIR}

mkdir -p ${builddir}/bin
mkdir -p ${out}/bin

prepare_wrapper() {
    name=$1
    template=$2

    tmp=${builddir}/bin/${name}
    cp ${template} ${tmp}
    sed -i \
        -e s:@prog@:${name}: \
        -e s:@bash@:${bash_program}: \
        -e s:@shell@:${bash_program}: \
        -e s:@binutils@:${binutils}: \
        -e s:@glibc@:${glibc}: \
        ${tmp}
    chmod +x ${tmp}
    cp ${tmp} ${out}/bin
}

# bespoke wrappers
prepare_wrapper ar ${src}/ar-wrapper.sh
prepare_wrapper ld ${src}/ld-wrapper.sh
prepare_wrapper strip ${src}/strip-wrapper.sh

# TODO: objcopy needs more care than we take here.
#       Need to preserve the same sections that
#       we keep in strip for example

ln -s ${binutils}/bin/addr2line ${out}/bin
ln -s ${binutils}/bin/as ${out}/bin
ln -s ${binutils}/bin/c++filt ${out}/bin
ln -s ${binutils}/bin/elfedit ${out}/bin
ln -s ${binutils}/bin/gprof ${out}/bin
ln -s ${binutils}/bin/nm ${out}/bin
ln -s ${binutils}/bin/objcopy ${out}/bin
ln -s ${binutils}/bin/objdump ${out}/bin
ln -s ${binutils}/bin/ranlib ${out}/bin
ln -s ${binutils}/bin/readelf ${out}/bin
ln -s ${binutils}/bin/size ${out}/bin
ln -s ${binutils}/bin/strings ${out}/bin

# omit ld.bfd,  that's deliberately excluded
