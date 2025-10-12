#!/bin/bash

set -e

echo
echo "chmod=${chmod}"
echo "bash=${bash}"
echo "coreutils=${coreutils}"
echo "sysroot=${nxfs_sysroot_0}"
echo "patchelf=${patchelf}"
echo "tar=${tar}"
echo "out=${out}"
echo "TMP=${TMP}"
echo

export PATH=${patchelf}/bin:${coreutils}/bin:${tar}/bin

mkdir ${out}

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

mkdir ${staging}

(cd ${nxfs_sysroot_0} && (tar cf - . | tar xf - -C ${staging}))

ld_staging=${staging}/${ld_relpath}
libc_staging=${staging}/${libc_relpath}

echo "staging dynamic linker: ${ld_staging}"
echo "staging libc:           ${libc_staging}"

ld_final=${out}/${ld_relpath}
libc_final=${out}/${libc_relpath}

echo "final   dynamic linker: ${ld_final}"
echo "final   libc:           ${libc_final}"

old_interp=$(patchelf --print-interpreter ${libc_staging})
echo "libc interpreter (before redirecting): ${old_interp}"

# first need to open up write permission..
chmod u+w ${staging}
chmod u+w ${staging}/usr/bin
chmod u+w ${staging}/${lib_relpath}
chmod u+w ${libc_staging}

patchelf --set-interpreter ${ld_final} ${libc_staging}

new_interp=$(patchelf --print-interpreter ${libc_staging})
echo "libc interpreter (after redirecting): ${new_interp}"

# also want to make some programs in ${staging}/usr/bin usable

redirect_elf_file() {
    local file=$1

    chmod u+w ${file}
    patchelf --set-interpreter ${ld_final} ${file}
    patchelf --set-rpath ${out}/usr/lib:${out}/lib ${file}
}

redirect_elf_file ${staging}/usr/bin/gencat
redirect_elf_file ${staging}/usr/bin/getconf
redirect_elf_file ${staging}/usr/bin/getent
redirect_elf_file ${staging}/usr/bin/iconv
redirect_elf_file ${staging}/usr/bin/locale
redirect_elf_file ${staging}/usr/bin/localedef
redirect_elf_file ${staging}/usr/bin/makedb
redirect_elf_file ${staging}/usr/bin/pcprofiledump
redirect_elf_file ${staging}/usr/bin/pldd
redirect_elf_file ${staging}/usr/bin/sprof
redirect_elf_file ${staging}/usr/bin/zdump

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (tar cf - . | tar xf - -C ${final}))
