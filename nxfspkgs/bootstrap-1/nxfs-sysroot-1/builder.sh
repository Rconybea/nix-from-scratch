#!/bin/bash

set -e

echo
echo "mkdir=${mkdir}";
echo "chmod=${chmod}";
#echo "ls=${ls}";
#echo "touch=${touch}";
#echo "whoami=${whoami}";
echo "bash=${bash}";
echo "sysroot=${nxfs_sysroot_0}"
echo "patchelf=${patchelf}"
echo "tar=${tar}"
echo "out=${out}"
echo "TMP=${TMP}"
echo

#echo "builder running as [$(${whoami})]"

${mkdir} ${out}

lib_relpath=lib
ld_relpath=${lib_relpath}/ld-linux-x86-64.so.2
libc_relpath=${lib_relpath}/libc.so.6

ld_stage0=${nxfs_sysroot_0}/${ld_relpath}
libc_stage0=${nxfs_sysroot_0}/${libc_relpath}

# ----------------------------------------------------------------
# verify initial paths

ok=1

if [[ ! -f ${ld_stage0} ]]; then
    echo "error: bad path to ld [${ld_stage0}]"
    ok=0
fi

if [[ ! -f ${libc_stage0} ]]; then
    echo "error: bad path to libc [${libc_stage0}]"
    ok=0
fi

if [[ ${ok} -eq 0 ]]; then
    exit 1
fi

echo "stage0  dynamic linker: ${ld_stage0}"
echo "stage0  libc:           ${libc_stage0}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}/sysroot

${mkdir} ${staging}

(cd ${nxfs_sysroot_0} && (${tar} cf - . | ${tar} xf - -C ${staging}))

#echo "staging:"
#${ls} -l ${staging}
#echo "${staging}/lib:"
#${ls} -l ${staging}/lib

#echo "staging/${libc_relpath}:"
#${ls} -l ${staging}/${libc_relpath}"

ld_staging=${staging}/${ld_relpath}
libc_staging=${staging}/${libc_relpath}

echo "staging dynamic linker: ${ld_staging}"
echo "staging libc:           ${libc_staging}"

ld_final=${out}/${ld_relpath}
libc_final=${out}/${libc_relpath}

echo "final   dynamic linker: ${ld_final}"
echo "final   libc:           ${libc_final}"

old_interp=$(${patchelf} --print-interpreter ${libc_staging})
echo "libc interpreter (before redirecting): ${old_interp}"

# first need to open up write permission..
${chmod} u+w ${staging}
${chmod} u+w ${staging}/${lib_relpath}
${chmod} u+w ${libc_staging}

${patchelf} --set-interpreter ${ld_final} ${libc_staging}

${chmod} u-w ${libc_staging}
${chmod} u-w ${staging}/${lib_relpath}
${chmod} u-w ${staging}

new_interp=$(${patchelf} --print-interpreter ${libc_staging})
echo "libc interpreter (after redirecting): ${new_interp}"

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (${tar} cf - . | ${tar} xf - -C ${final}))
