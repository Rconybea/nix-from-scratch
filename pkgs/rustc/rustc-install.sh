#!/bin/bash

set -euo pipefail

self_name=$(basename $0)

usage() {
    echo "$self_name: --prefix=PREFIX --docdir=DOCDIR"
}

declare prefix
prefix=
declare docdir
docdir=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        --docdir=*)
            docdir=${1#*=}
            ;;
        *)
            echo "error: ${self_name}: unexpected argument [$1]"
            ;;
    esac

    shift
done

echo prefix=${prefix}
echo docdir=${docdir}
echo cwd=$(pwd)

set -x
python3 ../src/x.py install rustc std
install -vm755 build/host/stage1-tools/*/*/{cargo,cargo-clippy,cargo-fmt,clippy-driver,rustfmt} ${prefix}/bin
install -vDm644 ../src/src/tools/cargo/src/etc/_cargo $prefix/share/zsh/site-functions/_cargo

mkdir -p ${docdir}/man/man1
install -vm644 ../src/src/tools/cargo/src/etc/man/* ${docdir}/man/man1
rm -fv ${docdir}/*.old
install -vm644 ../src/README.md ${docdir}

# omitting zsh stuff:
#   install -vdm755 /usr/share/zsh/site-functions
#   ln -sfv /opt/rustc/share/zsh/site-functions/_cargo /usr/share/zsh/site-functions




