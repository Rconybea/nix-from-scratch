#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --src-dir=SRCDIR --build-dir=BUILDDIR --cflags=CFLAGS --ldflags=LDFLAGS --configure-extra-args=ARGS"
}

prefix=
src_dir=
build_dir=
cflags=
ldflags=
configure_extra_args=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        --src-dir=*)
            src_dir=${1#*=}
            ;;
        --build-dir=*)
            build_dir=${1#*=}
            ;;
        --cflags=*)
            cflags=${1#*=}
            ;;
        --ldflags=*)
            ldflags=${1#*=}
            ;;
        --configure-extra-args=*)
            configure_extra_args=${1#*=}
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

rm -f state/config.result
mkdir -p ${build_dir}
(cd ${build_dir} && ../${src_dir}/configure --prefix=${prefix} CFLAGS="${cflags}" LDFLAGS="${ldflags}" ${configure_extra_args})
cp state/patch.result state/config.result

# end configure-autotools.sh
