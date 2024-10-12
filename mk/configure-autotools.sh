#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --src-dir=SRCDIR --build-dir=BUILDDIR --configure-exec=CONFIGEXEC --configure-script=CONFIGURE--cflags=CFLAGS --ldflags=LDFLAGS --configure-extra-args=ARGS"
}

prefix=
src_dir=
build_dir=
pre_configure_hook=true
configure_exec=
configure_script=configure
cflags=
cppflags=
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
        --pre-configure-hook=*)
            tmp=${1#*=}
            if [[ -n ${tmp} ]]; then
                pre_configure_hook=${tmp}
            fi
            ;;
        --configure-exec=*)
            tmp=${1#*=}
            if [[ -n ${tmp} ]]; then
                configure_exec=${tmp}
                configure_script=
            fi
            ;;
        --configure-script=*)
            tmp=${1#*=}
            if [[ -n ${tmp} ]]; then
                configure_script=${tmp}
                configure_exec=
            fi
            ;;
        --cflags=*)
            cflags=${1#*=}
            ;;
        --cppflags=*)
            cppflags=${1#*=}
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

# 1. if ${cflags} is empty, omit CFLAGS=${cflags} entirely.
#    (for example zlib configure doesn't accept the flag).
# 2. Surrounding with quotes doesn't work, at least not for the 'flex' package.

cflags_arg=
if [[ -n ${cflags} ]]; then
    cflags_arg="CFLAGS=${cflags}"
fi

cppflags_arg=
if [[ -n ${cppflags} ]]; then
    cppflags_arg="CPPFLAGS=${cppflags}"
fi

ldflags_arg=
if [[ -n "$ldflags" ]]; then
    ldflags_arg="LDFLAGS=${ldflags}"
fi

echo cflags_arg=${cflags_arg}
echo cppflags_arg=${cppflags_arg}
echo ldflags_arg=${ldflags_arg}

set -e

pushd ${build_dir}

${pre_configure_hook}

# Boilerplate here because "" and <nothing> are not the same thing,
# and we need to handle ${cflags_arg} / ${ldflags_arg} that contain spaces
#
if [[ -n ${configure_exec} ]]; then
    # e.g. configure_exec=cmake
    # In this case ${cflags_arg}, ${cppflags_arg}, ${ldflags_arg} won't work,
    # pass as regular cmake arguments
    #
    2>&1 echo ${configure_exec} ${configure_extra_args}..
    ${configure_exec} ${configure_extra_args}
else
    if [[ -n ${cflags_arg} ]]; then
        if [[ -n ${cppflags_arg} ]]; then
            if [[ -n ${ldflags_arg} ]]; then
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args} "${cflags_arg}" "${cppflags_arg}" "${ldflags_arg}"
            else
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args} "${cflags_arg}" "${cppflags_arg}"
            fi
        else
            if [[ -n ${ldflags_arg} ]]; then
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args} "${cflags_arg}" "${ldflags_arg}"
            else
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args} "${cflags_arg}" 
            fi
        fi
    else
        if [[ -n ${cppflags_arg} ]]; then
            if [[ -n ${ldflags_arg} ]]; then
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args} "${cppflags_arg}" "${ldflags_arg}"
            else
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args} "${cppflags_arg}"
            fi
        else
            if [[ -n ${ldflags_arg} ]]; then
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args} "${ldflags_arg}"
            else
                ../${src_dir}/${configure_script} --prefix=${prefix} ${configure_extra_args}
            fi
        fi
    fi
fi

popd

cp -f state/patch.result state/config.result

# end configure-autotools.sh
