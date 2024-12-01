#!/bin/bash

set -e

echo
echo "chmod=${chmod}";
echo "bash=${bash}";
echo "basename=${basename}";
echo "head=${head}";
echo "mkdir=${mkdir}";
echo "nxfs_sysroot_1=${nxfs_sysroot_1}";
echo "nxfs_coreutils_0=${nxfs_coreutils_0}";
echo "redirect_elf_file=${redirect_elf_file}";
echo "target_interpreter=${target_interpreter}";
echo "target_runpath=${target_runpath}";
echo "TMP=${TMP}"
echo

${mkdir} ${out}

# libc: only as smoke test for valid sysroot
libc=${nxfs_sysroot_1}/lib/libc.so.6

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

echo "stage0 coreutils dir: ${nxfs_coreutils_0}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy bash to temporary staging dir
#
staging=${TMP}

${mkdir} -p ${staging}

(cd ${nxfs_coreutils_0} && (${tar} cf - . | ${tar} xf - -C ${staging}))

${chmod} u+w ${staging}
${chmod} u+w ${staging}/bin
${chmod} u+w ${staging}/libexec/coreutils

for dir in ${staging}/bin ${staging}/libexec/coreutils; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            redirect_elf_file ${file} ${target_interpreter} ${target_runpath}
        else
            echo "skip non-regular-file [${file}]"
        fi
    done
done

${chmod} u-w ${staging}/libexec/coreutils
${chmod} u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (${tar} cf - . | ${tar} xf - -C ${final}))
