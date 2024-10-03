#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --name=NAME --prefix=PREFIX --srcdir=SRCDIR"
}

name=
prefix=
src_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --name=*)
            name=${1#*=}
            ;;
        --prefix=*)
            prefix=${1#*=}
            ;;
        --srcdir=*)
            src_dir=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${name} ]]; then
    2>&1 echo "error: $self_name}: expected non-empty NAME"
    exit 1
fi

if [[ -z ${prefix} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX"
    exit 1
fi

if [[ -z ${src_dir} ]]; then
    2>&1 echo "error: ${self_name}: expect non-empty SRCDIR"
    exit 1
fi

# missing doc ingredients
(cd ${src_dir} && install -v -m644 doc/*.html ${prefix}/share/doc/${name})
(cd ${src_dir} && install -v -m644 doc/*.css ${prefix}/share/doc/${name})
