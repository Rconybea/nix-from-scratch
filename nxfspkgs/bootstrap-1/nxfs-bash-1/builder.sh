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
echo "gnutar=${gnutar}";
echo "coreutils=${coreutils}";
echo "bash=${bash}";
echo "nxfs_toolchain_1=${nxfs_toolchain_1}";
echo "nxfs_bash_0=${nxfs_bash_0}";
echo "redirect_elf_file_0=${redirect_elf_file_0}";
echo "TMP=${TMP}"
echo

# not feasible, see R3 above
#export PATH=${tar}/bin:${patchelf}/bin:${coreutils}/bin

# see R3 above
#
mkdir=${coreutils}/bin/mkdir
readlink=${coreutils}/bin/readlink
chmod=${coreutils}/bin/chmod
tar=${gnutar}/bin/tar
patchelf=${patchelf}/bin/patchelf

# ----------------------------------------------------------------
# defines bash functions
#   invoke0()
#   redirect_elf_file_0()
#
source ${redirect_elf_file_0}

# ----------------------------------------------------------------
# local variables

# smoke test -- just verifying it exists
libc=${nxfs_toolchain_1}/lib/libc.so.6

target_interpreter=$(invoke0 ${readlink} -f ${nxfs_toolchain_1}/bin/ld.so)
target_runpath="${nxfs_toolchain_1}/lib"

invoke0 ${mkdir} ${out}

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

invoke0 ${mkdir} -p ${staging}

(cd ${nxfs_bash_0} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${staging}))

bash_staging=${staging}/bin/bash

echo "staging bash: ${bash_staging}"

old_runpath=$(invoke0 ${patchelf} --print-rpath ${bash_staging})

echo "bash runpath (before redirecting): ${old_runpath}"

invoke0 ${chmod} u+w ${staging}
invoke0 ${chmod} u+w ${staging}/bin
invoke0 ${chmod} u+w ${bash_staging}

redirect_elf_file_0 ${bash_staging} ${target_interpreter} ${target_runpath}

invoke0 ${chmod} u-w ${bash_staging}
invoke0 ${chmod} u-w ${staging}/bin
invoke0 ${chmod} u-w ${staging}

# ----------------------------------------------------------------
# copy to final destination
#
final=${out}

(cd ${staging} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${final}))

# ----------------------------------------------------------------
# verify bash runs without invoke0 crutch

${out}/bin/bash --version
