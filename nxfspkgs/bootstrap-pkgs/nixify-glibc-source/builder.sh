#! /bin/bash

# -e          : stop on first error
# -u          : error if variable not defined
# -o pipefail : report error code for last process in pipeline
#
set -euo pipefail

set -x

#echo "PATH=$PATH"

bash_program=${shell} # ${shell}/bin/bash
python_program=$(which python3); # ${python}/bin/python3
sort_program=$(which sort); # ${coreutils}/bin/sort
#file_program=${file}/bin/file

mkdir ${out}

(cd ${src} && (tar cf - . | tar xf - -C ${out}))
chmod -R +w ${out}

cd ${out}

sed -i -e 's:\$(localstatedir)/db:\$(localstatedir)/lib/nss_db:' ./Makeconfig
sed -i -e 's:/var/db/nscd/:/var/cache/nscd/:' ./nscd/nscd.h
sed -i -e 's:VAR_DB = /var/db:VARDB = /var/lib/nss_db:' ./nss/db-Makefile
sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/generic/paths.h
sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/unix/sysv/linux/paths.h

sed -i -e "s:/bin/bash:${bash_program}:" ./Makefile
sed -i -e "s:/bin/sh:${bash_program}:" ./sysdeps/generic/paths.h
sed -i -e "s:/bin/sh:${bash_program}:" ./sysdeps/unix/sysv/linux/paths.h

sed -i -e '/^define SHELL_NAME/ s:"sh":"bash":' -e "s:/bin/sh:${bash_program}:" ./sysdeps/posix/system.c

sed -i -e "s:/bin/sh:${bash_program}:" ./libio/oldiopopen.c
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/build-many-glibcs.py
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/cross-test-ssh.sh
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/config.guess
sed -i -e "s:/bin/sh:${bash_program}:" ./scripts/dso-ordering-test.py
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-vfork3.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/test-errno.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-fexecve.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-spawn3.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/tst-execveat.c
sed -i -e "s:/bin/sh:${bash_program}:" ./posix/bug-regex9.c
sed -i -e "s:/bin/sh:${bash_program}:" ./elf/tst-valgrind-smoke.sh
sed -i -e "s:/bin/sh:${bash_program}:" ./debug/xtrace.sh

find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/sh:#!'${bash_program}':' xx
find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/bash:#!'${bash_program}':' xx
find . -type f | xargs --replace=xx sed -i -e '1s:#! */usr/bin/python3:#!'${python_program}':' xx

# patch: fix bad function signature on locfile_hash() in locfile-kw.h, and charmap_hash() in charmap-kw.h
#
sed -i -e '/^locfile_hash/s:register unsigned int len:register size_t len:' locale/programs/locfile-kw.h
sed -i -e '/^charmap_hash/s:register unsigned int len:register size_t len:' locale/programs/charmap-kw.h

# note: the 'locale' program does not honor this.  However setlocale() does.
export LOCPATH=${locale_archive}/lib/locale

find ${out} -name '*.awk' | xargs --replace={} sed -i -e 's:LC_ALL=C sort -u:lc-all-sort-wrapper -u:' {}
find ${out} -name '*.awk' | xargs --replace={} sed -i -e 's:sort -t:'${sort_program}' -t:' -e 's:sort -u:'${sort_program}' -u:' {}
(find ${out} -name '*.awk' | xargs --replace={} grep sort {} ) || true
