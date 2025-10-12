#!/bin/bash

set -euo pipefail

echo
echo "coreutils=${coreutils}"
echo "patchelf=${patchelf}"
echo "tar=${tar}"
echo "bash=${bash}"
echo "toolchain=${toolchain}";
echo "redirect_elf_file=${redirect_elf_file}";

echo "nxfs_findutils_0=${nxfs_findutils_0}"

echo "TMP=${TMP}"

PATH=${tar}/bin:${bash}/bin:${patchelf}/bin:${coreutils}/bin

# ----------------------------------------------------------------
# helper bash script

source "${redirect_elf_file}/bootstrap-scripts/redirect-elf-file.sh"

# ----------------------------------------------------------------
# local variables

mkdir ${out}

# libc: only as smoke test for valid sysroot
libc=${toolchain}/lib/libc.so.6

target_interpreter=$(readlink -f ${toolchain}/bin/ld.so)
target_runpath="${toolchain}/lib"

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

mkdir -p ${staging}

(cd ${nxfs_findutils_0} && (tar cf - . | tar xf - -C ${staging}))

chmod u+w ${staging}
chmod u+w ${staging}/bin
#chmod u+w ${staging}/libexec/coreutils

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

#chmod u-w ${staging}/libexec/coreutils
chmod u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (tar cf - . | tar xf - -C ${final}))

# ----------------------------------------------------------------
# verify runnable executable

${out}/bin/find --version
