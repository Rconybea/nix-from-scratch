#!/bin/bash

set -e

echo
echo "chmod=${chmod}";
echo "bash=${bash}";
echo "mkdir=${mkdir}";
echo "nxfs_sysroot_1=${nxfs_sysroot_1}";
echo "nxfs_bash_0=${nxfs_bash_0}";
echo "redirect_elf_file=${redirect_elf_file}";
echo "target_interpreter=${target_interpreter}";
echo "target_runpath=${target_runpath}";
echo "TMP=${TMP}"
echo

set -e

${mkdir} ${out}

libc=${nxfs_sysroot_1}/lib/libc.so.6

# ----------------------------------------------------------------
# helper bash function

# defines bash function redirect_elf_file()
source ${redirect_elf_file}

# ----------------------------------------------------------------
# verify initial paths

ok=1

if [[ ! -f ${libc} ]]; then
    echo "error: bad path to libc [${libc}]"
    ok=0
fi

echo "stage0 bash dir: ${nxfs_bash_0}"
echo "stage1 libc:     ${libc}"

# ----------------------------------------------------------------
# copy bash to temporary staging dir
#
staging=${TMP}

${mkdir} -p ${staging}

(cd ${nxfs_bash_0} && (${tar} cf - . | ${tar} xf - -C ${staging}))

bash_staging=${staging}/bin/bash

echo "staging bash: ${bash_staging}"

old_runpath=$(${patchelf} --print-rpath ${bash_staging})

echo "bash runpath (before redirecting): ${old_runpath}"

${chmod} u+w ${staging}
${chmod} u+w ${staging}/bin
${chmod} u+w ${bash_staging}

redirect_elf_file ${bash_staging} ${target_interpreter} ${target_runpath}

#${patchelf} --set-interpreter ${nxfs_sysroot_1}/lib64/ld-linux-x86-64.so.2 ${bash_staging}
#${patchelf} --set-rpath ${nxfs_sysroot_1}/usr/lib:${nxfs_sysroot_1}/lib ${bash_staging}

${chmod} u-w ${bash_staging}
${chmod} u-w ${staging}/bin
${chmod} u-w ${staging}

#new_runpath=$(${patchelf} --print-rpath ${bash_staging})

#echo "bash runpath (after redirecting): ${new_runpath}"

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (${tar} cf - . | ${tar} xf - -C ${final}))
