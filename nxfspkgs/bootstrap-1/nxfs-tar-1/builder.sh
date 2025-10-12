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
# - patched coreutils
#
# For SANDBOX builds, remarks from nxfs-toolchain-0 apply,
# but only to unpatched executables.
#
# In this builder we can usefully set PATH for example.
# We still need to ues the invoke0 crutch for tar
#
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
#
#

set -euo pipefail

echo
echo "gnutar=${gnutar}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "patchelf=${patchelf}"
echo "toolchain=${toolchain}"
echo "redirect_elf_file_0=${redirect_elf_file_0}"
echo "TMP=${TMP}"
echo

export PATH=${coreutils}/bin:${patchelf}/bin

# see R3 above
#
tar=${gnutar}/bin/tar

# ----------------------------------------------------------------
# defines bash functions
#   invoke0()
#   redirect_elf_file_0()
#
# NOTE: We would be able to use redirect_elf_file() at this point,
# but we need invoke0() for tar
#
source ${redirect_elf_file_0}

# ----------------------------------------------------------------
# local variables

# libc: smoke test for valid sysroot
libc=${toolchain}/lib/libc.so.6

target_interpreter=$(readlink -f ${toolchain}/bin/ld.so)
target_runpath="${toolchain}/lib"

mkdir ${out}

# ----------------------------------------------------------------
# verify initial paths

ok=1

if [[ ! -f ${libc} ]]; then
    echo "error: bad path to libc [${libc}]"
    ok=0
fi

echo "stage0 tar dir:       ${tar}"
echo "stage1 libc:          ${libc}"

# ----------------------------------------------------------------
# copy to temporary staging dir
#
staging=${TMP}

mkdir -p ${staging}

(cd ${gnutar} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${staging}))

chmod u+w ${staging}
chmod u+w ${staging}/bin

for dir in ${staging}/bin; do
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -f ${file} ]]; then
            redirect_elf_file_0 ${file} ${target_interpreter} ${target_runpath}
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

(cd ${staging} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${final}))

# ----------------------------------------------------------------
# verify executable runs without invoke0 crutch

${out}/bin/tar --version
