#!/bin/bash
#
# Promise:
# 1. state/expected.sha256 looks like
#      <SHA256> <TARBALL>
# 2. preserves state/expected.sha256 file modification time
#    when contents did not change

self_name=$(basename ${0})

usage() {
    echo "$self_name: --tarball-path=TARBALL --build-dir=BUILDDIR"
}

tarball_path=
build_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --tarball-path=*)
            tarball_path="${1#*=}"
            ;;
        --build-dir=*)
            build_dir="${1#*=}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${tarball_path} ]]; then
    2>&1 echo "$self_name: expected TARBALL (use --tarball-path=TARBALL)"
    exit 1
fi

if [[ -z ${build_dir} ]]; then
    2>&1 echo "$self_name: expected BUILDDIR (use --build-dir=BUILDDIR)"
    exit 1
fi

rm -f ${tarball_path}
rm -f ${build_dir}
rm -f state/*
rm -f log/*

# end distclean.sh
