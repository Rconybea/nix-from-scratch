#!/bin/bash

set -e

echo
echo "chmod=${chmod}";
echo "bash=${bash}";
echo "basename=${basename}";
echo "head=${head}";
echo "mkdir=${mkdir}";
echo "tar=${tar}";
echo "nxfs_sysroot_1=${nxfs_sysroot_1}";
echo "nxfs_libxcrypt_0=${nxfs_libxcrypt_0}";
echo "redirect_elf_file=${redirect_elf_file}";
echo "target_interpreter=${target_interpreter}";
echo "target_runpath=${target_runpath}";
echo "TMP=${TMP}"
echo

${mkdir} ${out}

# libc: only as smoke test for valid sysroot
libc=${nxfs_sysroot_1}/lib/libc.so.6

src=${nxfs_libxcrypt_0}

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

echo "stage0 libxcrypt dir: ${nxfs_libxcrypt_0}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

${mkdir} -p ${staging}

(cd ${src} && (${tar} cf - . | ${tar} xf - -C ${staging}))

${chmod} -R u+w ${staging}

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

(cd ${staging} && (${tar} cf - . | ${tar} xf - -C ${final}))
