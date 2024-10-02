#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX"
}

prefix=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${prefix} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX"
    exit 1
fi

# from LFS: a few programs don't know about flex, and try to run lex instead.
# Redirect these programs to flex;  flex will emulate lex when invoked under that name.

ln -sfv flex ${prefix}/bin/lex
ln -sfv flex.1 ${prefix}/share/man/man1/lex.1
