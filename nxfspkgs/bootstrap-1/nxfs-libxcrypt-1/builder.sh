#!/bin/bash

set -e

echo
echo "libxcrypt=${libxcrypt}"
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

src=${libxcrypt}

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

echo "stage0 libxcrypt dir: ${libxcrypt}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

mkdir -p ${staging}

(cd ${src} && (tar cf - . | tar xf - -C ${staging}))

chmod -R u+w ${staging}

for dir in ${staging}/lib; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            redirect_elf_file ${file} ${target_interpreter} ${target_runpath}
        else
            echo "skip non-regular-file [${file}]"
        fi
    done
done

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (tar cf - . | tar xf - -C ${final}))
