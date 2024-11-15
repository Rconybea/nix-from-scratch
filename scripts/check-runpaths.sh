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
    2>&1 echo "$self_name: expected PREFIX (use --prefix=PREFIX)"
fi

if [[ ! -d ${prefix} ]]; then
    2>&1 echo "$self_name: PREFIX: expected directory: [${prefix}]"
fi

if [[ -d ${prefix}/bin ]]; then
    cd ${prefix}/bin

    for file in *; do
        elf_exe=$(file $file | grep 'ELF.*executable')

        if [[ -n $elf_exe ]]; then
            runpath=$(readelf -d $file | grep RUNPATH | sed -e 's|^.* Library runpath: ||')
            printf "%20s: %s\n" $file "$runpath"
        fi
    done
fi

# end check-runpaths.sh
