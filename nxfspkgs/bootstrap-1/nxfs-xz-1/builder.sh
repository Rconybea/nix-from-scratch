#!/bin/bash

set -e

echo
echo "xz=${xz}"
echo "sed=${sed}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "patchelf=${patchelf}"
echo "bash=${bash}"
echo "toolchain=${toolchain}"
echo "redirect_elf_file=${redirect_elf_file}"
echo "TMP=${TMP}"
echo

export PATH=${sed}/bin:${tar}/bin:${coreutils}/bin:${patchelf}/bin

# ----------------------------------------------------------------
# helper bash script

source "${redirect_elf_file}"

# ----------------------------------------------------------------

mkdir ${out}

# libc: only as smoke test for valid sysroot
libc=${toolchain}/lib/libc.so.6

target_interpreter=$(readlink -f ${toolchain}/bin/ld.so)
target_runpath="${out}/lib:${toolchain}/lib"

# ----------------------------------------------------------------
# verify initial paths

ok=1

if [[ ! -f ${libc} ]]; then
    echo "error: bad path to libc [${libc}]"
    ok=0
fi

echo "stage0 xz dir:        ${xz}"
echo "stage1 libc:          ${libc}"


# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

mkdir -p ${staging}

(cd ${xz} && (tar cf - . | tar xf - -C ${staging}))

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

        if $(is_elf_file ${file}); then
            :
        else
            sed -i -e '1s:#! */bin/bash:#!'${bash}':' ${file}
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

${out}/bin/xz --version
