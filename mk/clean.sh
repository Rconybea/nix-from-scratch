#!/bin/bash
#
# Promise:
# 1. state/expected.sha256 looks like
#      <SHA256> <TARBALL>
# 2. preserves state/expected.sha256 file modification time
#    when contents did not change

self_name=$(basename ${0})

usage() {
    echo "$self_name: --build-dir=BUILDDIR"
}

tarball_path=
build_dir=

while [[ $# > 0 ]]; do
    case "$1" in
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

if [[ -z ${build_dir} ]]; then
    2>&1 echo "$self_name: expected BUILDDIR (use --build-dir=BUILDDIR)"
    exit 1
fi

if [[ -d ${build_dir} ]]; then
    (cd ${build_dir} && (make clean || true))
fi

rm -f state/compile.result

# end clean.sh
