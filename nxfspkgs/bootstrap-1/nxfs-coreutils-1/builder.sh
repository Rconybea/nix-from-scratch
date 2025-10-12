#!/bin/bash
#
# BOOTSTRAP REMARKS:
# At this point in bootstrap, we have
# - nix store containing result of essential fixed-output derivations.
#   these derivations were built outside the nix store and refer to paths
#   that aren't accessible during nix-build.
# - patched toolchain {libc, gcc, binutils}
#   Not directly useful, but this is the destination we want to patch-in
#   to other imported packages, such as this one.
# - patched bash interpreter (running this script)
# - patched patchelf program
#
# For SANDBOX builds, remarks from nxfs-toolchain-0 still apply:
# - whenever we refer to a stage-0 executable, we will need to
#   R1. explicitly invoke the dynamic loader ${toolchain}/bin/ld.so
#   R2. explicitly supply toolchain library path ${toolchain}/lib
# - the bash instance running this script is also in an impaired state:
#   searching PATH for executables doesn't work
#   (possibly because requires R1 and R2 prevent bash recognizing
#    executables).  Instead have to:
#   R3. give full path to an executable
# - as we progressively introduce patched stage-1 packages,
#   we can retire the explicit invocation

set -euo pipefail

echo
echo "gnutar=${gnutar}"
echo "bash=${bash}"
echo "toolchain=${toolchain}"
echo "coreutils=${coreutils}"
echo "patchelf=${patchelf}"
echo "redirect_elf_file_0=${redirect_elf_file_0}"
echo "TMP=${TMP}"
echo

# not feasible, see R3 above
#export PATH=${gnutar}/bin:${coreutils}/bin:${patchelf}/bin

# see R3 above
#
mkdir=${coreutils}/bin/mkdir
readlink=${coreutils}/bin/readlink
chmod=${coreutils}/bin/chmod
tar=${gnutar}/bin/tar

# ----------------------------------------------------------------
# defines bash functions
#   invoke0()
#   redirect_elf_file_0()
#
source ${redirect_elf_file_0}

# ----------------------------------------------------------------
# local variables

# libc: smoke test for valid sysroot
libc=${toolchain}/lib/libc.so.6

target_interpreter=$(invoke0 ${readlink} -f ${toolchain}/bin/ld.so)
target_runpath="${toolchain}/lib"

invoke0 ${mkdir} ${out}

# ----------------------------------------------------------------
# verify initial paths

ok=1

if [[ ! -f ${libc} ]]; then
    echo "error: bad path to libc [${libc}]"
    ok=0
fi

echo "stage0 coreutils dir: ${coreutils}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy bash to temporary staging dir
#
staging=${TMP}

invoke0 ${mkdir} -p ${staging}

(cd ${coreutils} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${staging}))

invoke0 ${chmod} u+w ${staging}
invoke0 ${chmod} u+w ${staging}/bin
invoke0 ${chmod} u+w ${staging}/libexec/coreutils

for dir in ${staging}/bin ${staging}/libexec/coreutils; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            redirect_elf_file_0 ${file} ${target_interpreter} ${target_runpath}
        else
            echo "skip non-regular-file [${file}]"
        fi
    done
done

invoke0 ${chmod} u-w ${staging}/libexec/coreutils
invoke0 ${chmod} u-w ${staging}/bin

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${final}))

# ----------------------------------------------------------------
# verify at least one executable runs unassisted

${out}/bin/cat --version
