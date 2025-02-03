#! /bin/bash

set -e

echo "gzip=${gzip}"
echo "tar=${tar}"
echo "coreutils=${coreutils}"
echo "bash=${bash}"
echo "sysroot=${sysroot}"
echo "TMP=${TMP}"

export PATH=${gzip}/bin:${tar}/bin:${coreutils}/bin:${bash}/bin:${sysroot}/usr/bin

# will be copying stuff from ${sysroot}/usr/share/i18n
mkdir -p ${TMP}/locales
mkdir -p ${TMP}/charmaps

cp ${sysroot}/usr/share/i18n/charmaps/UTF-8.gz ${TMP}/charmaps/
(cd ${TMP}/charmaps && gunzip ./UTF-8.gz)

(cd ${sysroot}/usr/share/i18n/locales && (tar cf - . | tar xf - -C ${TMP}/locales))

mkdir -p ${out}
mkdir -p ${out}/lib/locale
mkdir -p ${out}/lib/locale/C.utf8

#export LOCALE_ARCHIVE=${out}/lib/locale/locale-archive

#(cd ${TMP}/locales && localedef --no-archive -i C     -c -f ../charmaps/UTF-8 ${out}/lib/locale/C.utf8)
mkdir -p ${TMP}/usr/lib/locale
(cd ${TMP}/locales && localedef --no-archive --prefix=${TMP} -i C     -c -f ../charmaps/UTF-8 C.utf8)
(cd ${TMP}/locales && localedef --no-archive --prefix=${TMP} -i en_US -c -f ../charmaps/UTF-8 en_US.utf8)
(cd ${TMP}/locales && localedef --no-archive --prefix=${TMP} -i en_AU -c -f ../charmaps/UTF-8 en_AU.utf8)

# try to setup locale-archive.
# Looks like "usr/lib/locale/" part of ${TMP}/usr/lib/locale/ is forced

#(cd ${TMP}/locales && localedef --prefix=${TMP} -i C     -c -f ./charmaps/UTF-8 --add-to-archive)
(cd ${TMP}/locales && localedef --add-to-archive --prefix=${TMP} -i C     -f ./charmaps/UTF-8)
(cd ${TMP}/locales && localedef --add-to-archive --prefix=${TMP} -i en_US -f ./charmaps/UTF-8)
(cd ${TMP}/locales && localedef --add-to-archive --prefix=${TMP} -i en_AU -f ./charmaps/UTF-8)

#localedef -i ./en_US -f ./UTF-8 --prefix=${TMP} --add-to-archive

#mkdir -p ${out}/lib/locale
mkdir -p ${out}/lib/locale
(cd ${TMP}/usr/lib/locale && (tar cf - . | tar xf - -C ${out}/lib/locale))

# demo
export LOCPATH=${out}/lib/locale

# wow.  turns out the locale program ignores LOCPATH,
# and only looks in compiled-in location
#
locale -a
