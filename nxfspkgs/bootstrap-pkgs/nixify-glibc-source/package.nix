{
  # stdenv :: derivation+attrset
  stdenv,
  # python :: derivation
  python,
  # coreutils :: derivation
  coreutils,
  # which :: derivation
  which,
  # locale-archive :: derivation
  locale-archive,
  # stageid :: string
  stageid
} :

let
  version = "2.40";
in

stdenv.mkDerivation {
  name = "nixify-glibc-source-${stageid}";
  version = version;

  src = builtins.fetchTarball { name = "glibc-${version}-source";
                                url = "https://ftpmirror.gnu.org/gnu/glibc/glibc-${version}.tar.xz";
                                sha256 = "0ncvsz2r8py3z0v52fqniz5lq5jy30h0m0xx41ah19nl1rznflkh";
                              };

  buildPhase = ''
    #! /bin/bash

    # -e          : stop on first error
    # -u          : error if variable not defined
    # -o pipefail : report error code for last process in pipeline
    #
    set -euo pipefail

    #echo "PATH=$PATH"

    python_program=$(which python3);
    sort_program=$(which sort);

    (cd $src && (tar cf - . | tar xf - -C $out))
    chmod -R +w $out

    cd $out

    sed -i -e 's:\$(localstatedir)/db:\$(localstatedir)/lib/nss_db:' ./Makeconfig
    sed -i -e 's:/var/db/nscd/:/var/cache/nscd/:' ./nscd/nscd.h
    sed -i -e 's:VAR_DB = /var/db:VARDB = /var/lib/nss_db:' ./nss/db-Makefile
    sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/generic/paths.h
    sed -i -e 's:"/var/db/":"/var/lib/nss_db":' ./sysdeps/unix/sysv/linux/paths.h

    sed -i -e "s:/bin/bash:$shell:" ./Makefile
    sed -i -e "s:/bin/sh:$shell:" ./sysdeps/generic/paths.h
    sed -i -e "s:/bin/sh:$shell:" ./sysdeps/unix/sysv/linux/paths.h

    sed -i -e '/^define SHELL_NAME/ s:"sh":"bash":' -e "s:/bin/sh:$shell:" ./sysdeps/posix/system.c

    sed -i -e "s:/bin/sh:$shell:" ./libio/oldiopopen.c
    sed -i -e "s:/bin/sh:$shell:" ./scripts/build-many-glibcs.py
    sed -i -e "s:/bin/sh:$shell:" ./scripts/cross-test-ssh.sh
    sed -i -e "s:/bin/sh:$shell:" ./scripts/config.guess
    sed -i -e "s:/bin/sh:$shell:" ./scripts/dso-ordering-test.py
    sed -i -e "s:/bin/sh:$shell:" ./posix/tst-vfork3.c
    sed -i -e "s:/bin/sh:$shell:" ./posix/test-errno.c
    sed -i -e "s:/bin/sh:$shell:" ./posix/tst-fexecve.c
    sed -i -e "s:/bin/sh:$shell:" ./posix/tst-spawn3.c
    sed -i -e "s:/bin/sh:$shell:" ./posix/tst-execveat.c
    sed -i -e "s:/bin/sh:$shell:" ./posix/bug-regex9.c
    sed -i -e "s:/bin/sh:$shell:" ./elf/tst-valgrind-smoke.sh
    sed -i -e "s:/bin/sh:$shell:" ./debug/xtrace.sh

    find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/sh:#!'$shell':' xx
    find . -type f | xargs --replace=xx sed -i -e '1s:#! */bin/bash:#!'$shell':' xx
    find . -type f | xargs --replace=xx sed -i -e '1s:#! */usr/bin/python3:#!'$python_program':' xx

    # patch: fix bad function signature on locfile_hash() in locfile-kw.h, and charmap_hash() in charmap-kw.h
    #
    sed -i -e '/^locfile_hash/s:register unsigned int len:register size_t len:' locale/programs/locfile-kw.h
    sed -i -e '/^charmap_hash/s:register unsigned int len:register size_t len:' locale/programs/charmap-kw.h

    # note: the 'locale' program does not honor this.  However setlocale() does.
    export LOCPATH=$locale_archive/lib/locale

    find $out -name '*.awk' | xargs --replace={} sed -i -e 's:LC_ALL=C sort -u:lc-all-sort-wrapper -u:' {}
    find $out -name '*.awk' | xargs --replace={} sed -i -e 's:sort -t:'$sort_program' -t:' -e 's:sort -u:'$sort_program' -u:' {}
    (find $out -name '*.awk' | xargs --replace={} grep sort {} ) || true
  '';

  #system = builtins.currentSystem;

  shell = stdenv.shell;
  locale_archive = locale-archive;

  buildInputs = [ python coreutils which locale-archive ];
}
