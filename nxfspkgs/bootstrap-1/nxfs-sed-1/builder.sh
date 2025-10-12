#!/bin/bash

set -euo pipefail

echo
echo "nxfs_gnused_0=${nxfs_gnused_0}"
echo "bash=${bash}"
echo "tar=${tar}"
echo "patchelf=${patchelf}"
echo "toolchain=${toolchain}"
echo "redirect_elf_file=${redirect_elf_file}"
echo "TMP=${TMP}"
echo

export PATH="${tar}/bin:${coreutils}/bin:${patchelf}/bin"

# ----------------------------------------------------------------
# local variables

# libc: only as smoke test for valid sysroot
libc=${toolchain}/lib/libc.so.6

target_interpreter=$(readlink -f ${toolchain}/bin/ld.so)
target_runpath="${toolchain}/lib"

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

echo "stage0 sed dir:       ${nxfs_gnused_0}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------

mkdir ${out}

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

mkdir -p ${staging}

(cd ${nxfs_gnused_0} && (tar cf - . | tar xf - -C ${staging}))

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

# ----------------------------------------------------------------
# verify patched executable runs

${out}/bin/sed --version
