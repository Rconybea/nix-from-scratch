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
echo "TMP=${TMP}"
echo

${mkdir} ${out}

libc=${nxfs_sysroot_1}/lib/libc.so.6

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
staging=${TMP}/bash

${mkdir} ${staging}

(cd ${nxfs_coreutils_0} && (${tar} cf - . | ${tar} xf - -C ${staging}))

elf_magic=$'\x7fELF'

${chmod} u+w ${staging}
${chmod} u+w ${staging}/bin
${chmod} u+w ${staging}/libexec/coreutils

for dir in ${staging}/bin ${staging}/libexec/coreutils; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            # read first 4 bytes for ELF magic
            header=$(${head} -c 4 "${file}")

            if [[ ${header} == ${elf_magic} ]]; then
                echo "accept elf file [${file}]"

                old_runpath=$(${patchelf} --print-rpath ${file})

                echo "$(${basename} $file) runpath (before redirecting): ${old_runpath}"

                ${chmod} u+w ${file}
                ${patchelf} --set-rpath ${nxfs_sysroot_1}/usr/lib:${nxfs_sysroot_1}/lib ${file}
                ${chmod} u-w ${file}

                new_runpath=$(${patchelf} --print-rpath ${file})

                echo "$(${basename} $file) runpath (after redirecting): ${new_runpath}"
            else
                echo "reject non-elf file [${file}] (doesn't begin with ELF magic)"
            fi
        else
            echo "reject non-regular-file [${file}]"
        fi
    done
done

${chmod} u-w ${staging}/libexec/coreutils
${chmod} u-w ${staging}/bin
${chmod} u-w ${staging}

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (${tar} cf - . | ${tar} xf - -C ${final}))
