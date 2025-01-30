#!/bin/bash

set -e

echo
echo "host_tuple=${host_tuple}"
echo "gcc_version=${gcc_version}"
echo "bash=${bash}"
echo "toolchain=${nxfs_toolchain_0}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "patchelf=${patchelf}"
echo "redirect_elf_file=${redirect_elf_file}"
echo "target_interpreter=${target_interpreter}"
echo "target_runpath=${target_runpath}"
echo "TMP=${TMP}"
echo

export PATH=${tar}/bin:${coreutils}/bin:${patchelf}/bin

mkdir ${out}

# ----------------------------------------------------------------
# helper bash script

source "${redirect_elf_file}"

# ----------------------------------------------------------------
# verify initial paths

echo "stage0 toolchain dir: ${toolchain}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

mkdir -p ${staging}

(cd ${toolchain} && (tar cf - . | tar xf - -C ${staging}))

chmod u+w ${staging}/bin
chmod u+w ${staging}/${host_tuple}
chmod u+w ${staging}/${host_tuple}/bin
chmod u+w ${staging}/libexec/gcc/${host_tuple}/${gcc_version}

for dir in ${staging}/bin ${staging}/${host_tuple}/bin ${staging}/libexec/gcc/${host_tuple}/${gcc_version}; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            redirect_elf_file ${file} ${target_interpreter} ${target_runpath}
        else
            echo "skip non-regular-file [${file}]"
        fi
    done
done

chmod u-w ${staging}/libexec/gcc/${host_tuple}/${gcc_version}
chmod u-w ${staging}/${host_tuple}/bin
chmod u-w ${staging}/${host_tuple}
chmod u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (tar cf - . | tar xf - -C ${final} ))
