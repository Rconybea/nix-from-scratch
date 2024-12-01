if [[ -z "${head}" ]]; then
    echo "expected non-empty variable \$head"
    exit 1
fi

if [[ -z "${basename}" ]]; then
    echo "expected non-empty variable \$basename"
    exit 1
fi

if [[ -z "${chmod}" ]]; then
    echo "expected non-empty variable \$chmod";
    exit 1
fi

if [[ -z "${patchelf}" ]]; then
    echo "expected non-empty variable \$patchelf";
    exit 1
fi

# caller must als provide global variabels:
#   head
#   basename
#   chmod
#   patchelf
#   nxfs_sysroot_1
#
# Use
#   redirect_elf_file ${file} ${new_interpreter} ${new_runpath}
#
redirect_elf_file() {
    local elf_magic=$'\x7fELF'
    local file=$1
    local target_interpreter=$2
    local target_runpath=$3

    # read first 4 bytes for ELF magic
    header=$(${head} -c 4 "${file}")

    if [[ ${header} == ${elf_magic} ]]; then
        echo "accept elf file [${file}]"

        old_runpath=$(${patchelf} --print-rpath ${file})

        echo "[$(${basename} $file)] runpath (before redirecting): ${old_runpath}"

        ${chmod} u+w ${file}

        #${patchelf} --set-rpath ${nxfs_sysroot_1}/usr/lib:${nxfs_sysroot_1}/lib ${file}
        ${patchelf} --set-rpath ${target_runpath} ${file}

        new_runpath=$(${patchelf} --print-rpath ${file})
        echo "[$(${basename} $file)] runpath (after redirecting): ${new_runpath}"

        if [[ -x ${file} ]]; then
            set +e
            old_interp=$(${patchelf} --print-interpreter ${file})
            err=$?
            set -e

            if [[ $err -eq 0 ]]; then
                echo "[$(${basename} $file)] interp (before redirecting): ${old_interp}"

                #${patchelf} --set-interpreter ${nxfs_sysroot_1}/lib64/ld-linux-x86-64.so.2 ${file}
                ${patchelf} --set-interpreter ${target_interpreter} ${file}

                new_interp=$(${patchelf} --print-interpreter ${file})

                echo "[$(${basename} $file)] interp (after redirecting): ${new_interp}"
            else
                echo "skip executable [$file] - no ELF interpreter to redirect"
            fi
        fi

        ${chmod} u-w ${file}

    else
        echo "skip non-elf file [${file}] (doesn't begin with ELF magic)"
    fi
}
