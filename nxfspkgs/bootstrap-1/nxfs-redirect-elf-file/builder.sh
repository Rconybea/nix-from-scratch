#!/bin/bash

set -e

echo
echo "cp=${cp}";
echo "mkdir=${mkdir}";
echo "redirect_elf_file=${redirect_elf_file}"
#echo "TMP=${TMP}"
echo

${mkdir} -p ${out}/bootstrap-scripts

${cp} ${redirect_elf_file} ${out}/bootstrap-scripts/redirect-elf-file.sh
