#!/bin/bash

set -e

echo
echo "coreutils=${coreutils}"
echo "patchelf=${patchelf}"
echo "tar=${tar}"
echo "bash=${bash}"

echo "nxfs_sysroot=${nxfs_sysroot}";
echo "redirect_elf_file=${redirect_elf_file}";
echo "target_interpreter=${target_interpreter}";
echo "target_runpath=${target_runpath}";

echo "nxfs_findutils_0=${nxfs_findutils_0}"

echo "TMP=${TMP}"


# libc: only as smoke test for valid sysroot
libc=${nxfs_sysroot}/lib/libc.so.6

PATH=${bash}/bin:${patchelf}/bin:${coreutils}/bin

mkdir ${out}

# ----------------------------------------------------------------
# helper bash script

chmod=${coreutils}/bin/chmod
basename=${coreutils}/bin/basename
head=${coreutils}/bin/head
mkdir=${coreutils}/bin/mkdir
patchelf=${patchelf}/bin/patchelf
tar=${tar}/bin/tar

source "${redirect_elf_file}/bootstrap-scripts/redirect-elf-file.sh"

# ----------------------------------------------------------------
# verify initial paths

ok=1

if [[ ! -f ${libc} ]]; then
    echo "error: bad path to libc [${libc}]"
    ok=0
fi

echo "stage0 findutils dir: ${nxfs_findutils_0}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy bash to temporary staging dir
#
staging=${TMP}

${mkdir} -p ${staging}

(cd ${nxfs_findutils_0} && (${tar} cf - . | ${tar} xf - -C ${staging}))

${chmod} u+w ${staging}
${chmod} u+w ${staging}/bin
#${chmod} u+w ${staging}/libexec/coreutils

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

#${chmod} u-w ${staging}/libexec/coreutils
${chmod} u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (${tar} cf - . | ${tar} xf - -C ${final}))
