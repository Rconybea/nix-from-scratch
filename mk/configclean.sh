#!/bin/bash
#

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

rm -rf ${build_dir}
rm -f state/config.result

# end configclean.sh
