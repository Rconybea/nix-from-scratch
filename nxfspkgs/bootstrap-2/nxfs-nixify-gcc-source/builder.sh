#! /bin/bash

# -e          : stop on first error
# -u          : error if variable not defined
# -o pipefail : report error code for last process in pipeline
#
set -euo pipefail

PATH=
for pkg in ${buildInputs}; do
    if [[ -d ${pkg} ]]; then
        if [[ -n ${PATH} ]]; then
            PATH+=":"
        fi
        PATH+=${pkg}/bin
    fi
done
export PATH

echo "PATH=$PATH"

bash_program=${bash}/bin/bash
file_program=${file}/bin/file

mkdir ${out}

(cd ${src} && (tar cf - . | tar xf - -C ${out}))
chmod -R +w ${out}

(cd ${out} && sed -i -e '/m64=/s:lib64:lib:' ./gcc/config/i386/t-linux64)
(cd ${out} && sed -i -e "1s:#!/bin/sh:#!${bash_program}:" move-if-change)
(cd ${out} && sed -i -e "s:/usr/bin/file:${file_program}:" ./libstdc++-v3/configure)
(cd ${out} && sed -i -e "s:/usr/bin/file:${file_program}:" ./libcc1/configure)
(cd ${out} && sed -i -e "s:/usr/bin/file:${file_program}:" ./gcc/configure)
(cd ${out} && sed -i -e "s:/usr/bin/file:${file_program}:" ./zlib/configure)
#
# in general:
#  - don't try to expand .l files (will trigger doc rebuild)
#  - replace shebangs: {/bin/sh, /usr/bin/env sh, /usr/bin/env bash} -> ${bash_program}
#
(cd ${out} && find . -type f | grep -v '*.l$' | xargs --replace=xx sed -i -e "1s:#! /bin/sh:#! ${bash_program}:" -e "1s:#!/usr/bin/env sh:#! ${bash_program}:" -e "#1:#!/usr/bin/env bash:#! ${bash_program}:" xx)
