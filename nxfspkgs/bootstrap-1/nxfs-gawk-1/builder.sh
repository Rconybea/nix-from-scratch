#!/bin/bash

set -e

echo
echo "nxfs_gawk_0=${nxfs_gawk_0}"
echo "chmod=${chmod}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "patchelf=${patchelf}"
echo "bash=${bash}"
echo "redirect_elf_file=${redirect_elf_file}"
echo "sysroot=${sysroot}"
echo "target_interpreter=${target_interpreter}"
echo "target_runpath=${target_runpath}"
echo "TMP=${TMP}"
echo

export PATH=${tar}/bin:${coreutils}/bin:${patchelf}/bin

mkdir ${out}

# libc: only as smoke test for valid sysroot
libc=${sysroot}/lib/libc.so.6

# ----------------------------------------------------------------
# helper bash script

source "${redirect_elf_file}"

# ----------------------------------------------------------------
# verify initial paths

ok=1

if [[ ! -f ${libc} ]]; then
    echo "error: bad path to libc [${libc}]"
    ok=0
fi

echo "stage0 gawk dir:      ${nxfs_gawk_0}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

mkdir -p ${staging}

(cd ${nxfs_gawk_0} && (tar cf - . | tar xf - -C ${staging}))

chmod u+w ${staging}
chmod u+w ${staging}/bin
chmod u+w ${staging}/lib/gawk
chmod u+w ${staging}/libexec/awk

for dir in ${staging}/bin; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            redirect_elf_file ${file} ${target_interpreter} ${target_runpath}
        else
            echo "skip non-regular-file [${file}]"
        fi
    done
done

chmod u-w ${staging}/libexec/awk
chmod u-w ${staging}/lib/gawk
chmod u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (tar cf - . | tar xf - -C ${final}))
