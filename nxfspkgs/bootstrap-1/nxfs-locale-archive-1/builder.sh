#! /bin/bash

set -euo pipefail

echo "nxfs_vars_file=${nxfs_vars_file}"
echo "toolchain=${toolchain}"
echo "findutils=${findutils}"
echo "gzip=${gzip}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "TMP=${TMP}"

set -x

# provides:
#   NIX_PREFIX
#   NXFS_TOOLCHAIN_PREFIX   (e.g. $HOME/nxfs-toolchain)
#   NXFS_HOST_TUPLE
#   NXFS_MAX_JOBS
# we need just NXFS_TOOLCHAIN_PREFIX here
#
source ${nxfs_vars_file}

export PATH=${findutils}/bin:${toolchain}/bin:${gzip}/bin:${tar}/bin:${coreutils}/bin:${bash}/bin

mkdir -p ${TMP}/i18n/charmaps
gunzip -c ${toolchain}/share/i18n/charmaps/UTF-8.gz > ${TMP}/i18n/charmaps/UTF-8

mkdir -p ${TMP}/out/${NXFS_TOOLCHAIN_PREFIX}/lib/locale
mkdir -p ${out}/lib/locale

export I18NPATH=${toolchain}/share/i18n:${TMP}/i18n

pushd ${TMP}/out

localedef --prefix=${TMP}/out -i C -f UTF-8 C.UTF-8
localedef --prefix=${TMP}/out -i en_US -f UTF-8 en_US.UTF-8
localedef --prefix=${TMP}/out -i en_AU -f UTF-8 en_AU.UTF-8

localedef --no-archive --prefix=${TMP}/out -i C -f UTF-8 C.UTF-8
localedef --no-archive --prefix=${TMP}/out -i en_US -f UTF-8 en_US.UTF-8
localedef --no-archive --prefix=${TMP}/out -i en_AU -f UTF-8 en_AU.UTF-8

popd

mkdir -p ${out}
cp -r ${TMP}/out/${NXFS_TOOLCHAIN_PREFIX}/lib ${out}

# demo
export LOCPATH=${out}/lib/locale
# or if you build a locale-archive:
export LOCALE_ARCHIVE=${out}/lib/locale/locale-archive

localedef --list-archive ${out}/lib/locale/locale-archive
