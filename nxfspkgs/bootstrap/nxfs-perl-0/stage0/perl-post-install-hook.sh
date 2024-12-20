#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX"
}

prefix=
runpath=
version_major_minor=

while [[ $# > 0 ]]; do
    case "$1" in
        --prefix=*)
            prefix=${1#*=}
            ;;
        --runpath=*)
            runpath=${1#*=}
            ;;
        --version-major-minor=*)
            version_major_minor=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${version_major_minor} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty VERSION_MAJOR_MINOR (use --version-major-minor=VERSION_MAJOR_MINOR)"
    exit 1
fi
if [[ -z ${prefix} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty PREFIX (use --prefix=PREFIX)"
    exit 1
fi
if [[ -z ${runpath} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty RUNPATH (use --runpath=RUNPATH)"
    exit 1
fi

set -e
set -x

libperl=${prefix}/lib/perl5/${version_major_minor}/core_perl/CORE/libperl.so

chmod u+w ${libperl}
patchelf --set-rpath ${runpath} ${libperl}
chmod u-w ${libperl}
