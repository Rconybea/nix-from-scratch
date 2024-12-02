#!/bin/bash

set -e

echo
echo "chmod=${chmod}";
echo "bash=${bash}";
echo "basename=${basename}";
echo "head=${head}";
echo "mkdir=${mkdir}";
echo "nxfs_toolchain_0=${nxfs_toolchain_0}";
echo "redirect_elf_file=${redirect_elf_file}";
echo "target_interpreter=${target_interpreter}";
echo "target_runpath=${target_runpath}";
echo "TMP=${TMP}"
echo

${mkdir} ${out}

# ----------------------------------------------------------------
# helper bash script

source "${redirect_elf_file}"

# ----------------------------------------------------------------
# verify initial paths

echo "stage0 toolchain dir: ${nxfs_toolchain_0}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

${mkdir} -p ${staging}

(cd ${nxfs_toolchain_0} && (${tar} cf - . | ${tar} xf - -C ${staging}))

${chmod} u+w ${staging}/bin
${chmod} u+w ${staging}/x86_64-pc-linux-gnu
${chmod} u+w ${staging}/x86_64-pc-linux-gnu/bin

for dir in ${staging}/bin ${staging}/x86_64-pc-linux-gnu/bin; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            redirect_elf_file ${file} ${target_interpreter} ${target_runpath}
        else
            echo "skip non-regular-file [${file}]"
        fi
    done
done

${chmod} u-w ${staging}/x86_64-pc-linux-gnu/bin
${chmod} u-w ${staging}/x86_64-pc-linux-gnu
${chmod} u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (${tar} cf - . | ${tar} xf - -C ${final}))
