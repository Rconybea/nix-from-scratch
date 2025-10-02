#!/bin/bash
#
# install step for autoconf projects

self_name=$(basename ${0})

usage() {
    echo "$self_name: --build-dir=BUILDDIR"
}

prepend_to_path=
tarball_path=
build_dir=
install_exec=make
install_args=install

while [[ $# > 0 ]]; do
    case "$1" in
        --prepend-to-path=*)
            prepend_to_path=${1#*=}
            ;;
        --install-exec=*)
            tmp=${1#*=}
            if [[ -z ${tmp} ]]; then
                # keep default
                :
            else
                install_exec=$tmp
            fi
            ;;
        --install-args=*)
            tmp=${1#*=}
            if [[ -z ${tmp} ]]; then
                # keep default
                :
            else
                install_args=${tmp}
            fi
            ;;
        --build-dir=*)
            build_dir="${1#*=}"
            ;;
        *)
            2>&1 echo "error: ${self_name}: unexpected argument ${1}"
            2>&1 usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${build_dir} ]]; then
    2>&1 echo "$self_name: expected BUILDDIR (use --build-dir=BUILDDIR)"
    exit 1
fi

if [[ ! -d ${build_dir} ]]; then
    2>&1 echo "$self_name: BUILDDIR: expected directory [${build_dir}]"
    exit 1
fi

rm -f state/install.result

# not correct: suppresses errors
#(cd ${build_dir} && make V=1 install) 2>&1 | tee log/install.log

pushd ${build_dir}

if [[ -n ${prepend_to_path} ]]; then
    PATH=${prepend_to_path}:$PATH
    2>&1 echo "PATH=${PATH}"
fi

${install_exec} ${install_args}

err=$?

popd

if [[ ${err} -ne 0 ]]; then
    echo err > state/install.result
    exit 1
fi

cp state/compile.result state/install.result

# end install-autotools.sh
