#!/bin/bash
#
# compile step for autoconf projects

self_name=$(basename ${0})

usage() {
    echo "$self_name: --build-dir=BUILDDIR --build-exec=BUILDEXEC --build-args=BUILDARGS"
}

tarball_path=
prepend_to_path=
build_exec=make
build_args=
build_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --prepend-to-path=*)
            prepend_to_path=${1#*=}
            ;;
        --build-exec=*)
            tmp=${1#*=}
            if [[ -n "$tmp" ]]; then
                build_exec=$tmp
            fi
            ;;
        --build-args=*)
            build_args=${1#*=}
            ;;
        --build-dir=*)
            build_dir=${1#*=}
            ;;
        *)
            2>&1 echo "error: ${self_name}: unexpected argument [$1]"
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

rm -f state/compile.result

# to debug make: use V=1
pushd ${build_dir}

#echo build_exec=${build_exec}

echo "${self_name}: BUILDEXEC=[${build_exec}] BUILDARGS=[${build_args}]"

if [[ -n ${prepend_to_path} ]]; then
    PATH=${prepend_to_path}:$PATH
    2>&1 echo "PATH=${PATH}"
fi

${build_exec} ${build_args} 2>&1

#(${build_exec} 2>&1 | tee ../log/compile.log)  # no good; suppresses errors
err=$?

popd

if [[ $err -ne 0 ]]; then
    echo err > state/compile.result
    exit 1
fi

cp state/patch.result state/compile.result

# end compile-autotools.sh
