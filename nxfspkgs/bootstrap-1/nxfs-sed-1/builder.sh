#!/bin/bash

set -e

echo
echo "nxfs_sed_0=${nxfs_sed_0}"
echo "bash=${bash}"
echo "basename=${basename}"
echo "tar=${tar}"
echo "patchelf=${patchelf}"
echo "sysroot=${sysroot}"
echo "redirect_elf_file=${redirect_elf_file}"
echo "target_interpreter=${target_interpreter}"
echo "target_runpath=${target_runpath}"
echo "TMP=${TMP}"
echo

export PATH="${tar}/bin:${coreutils}/bin:${patchelf}/bin"

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

echo "stage0 sed dir:       ${nxfs_sed_0}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

mkdir -p ${staging}

(cd ${nxfs_sed_0} && (tar cf - . | tar xf - -C ${staging}))

chmod u+w ${staging}
chmod u+w ${staging}/bin

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

chmod u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (tar cf - . | tar xf - -C ${final}))
