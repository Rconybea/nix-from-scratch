#!/bin/bash

set -euo pipefail

echo
echo "toolchain=${toolchain}"
echo "cp=${cp}";
echo "head=${head}";
echo "basename=${basename}";
echo "mkdir=${mkdir}";
echo "sed=${sed}";
echo "chmod=${chmod}";
echo "patchelf=${patchelf}";
echo "redirect_elf_file_0=${redirect_elf_file_0}"
echo "redirect_elf_file=${redirect_elf_file}"
#echo "TMP=${TMP}"
echo

# Invoke an executable with explicit dynamic loader and library paths.
# Intended for use with an unpatched executable imported into nix store
# as a fixed-output derivation
#
# Use
#   invoke0 path/to/executables args..
#
# Require:
#   Caller must provide global variable ${toolchain}
#
invoke0() {
    if [[ -z ${toolchain} ]]; then
        echo "invoke0 requires non-empty variable toolchain"
        exit 1
    fi

    ${toolchain}/bin/ld.so --library-path ${toolchain}/lib "${@}"
}


invoke0 ${mkdir} -p ${out}/bootstrap-scripts

invoke0 ${sed} \
        -e "s:@toolchain@:${toolchain}:g" \
        -e "s:@head@:${head}:g" \
        -e "s:@basename@:${basename}:g" \
        -e "s:@patchelf@:${patchelf}:g" \
        -e "s:@chmod@:${chmod}:g" \
        ${redirect_elf_file_0} \
        > ${out}/bootstrap-scripts/redirect-elf-file-0.sh

invoke0 ${cp} ${redirect_elf_file} ${out}/bootstrap-scripts/redirect-elf-file.sh
