#!/bin/bash
#
# Promise:
# 1. state/unpack.result contains:
#    - <SRC> on successful unpack
#    - error message if unpack failed
# 2. writes [log/unpack.log]
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --tarball-path=TARBALL --src-dir=SRC_DIR"
}

tarball_path=
tarball_unpack_dir=
src_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --src-dir=*)
            src_dir=${1#*=}
            ;;
        --tarball-unpack-dir=*)
            tarball_unpack_dir="${1#*=}"
            ;;
        --tarball-path=*)
            tarball_path="${1#*=}"
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
fi

if [[ ! -f ${tarball_path} ]]; then
    2>&1 echo "$self_name: expected file: [${tarball_path}]"
fi

if [[ -z ${tarball_unpack_dir} ]]; then
    tarball_unpack_dir=${src_dir}
fi

if [[ -z ${src_dir} ]]; then
    2>&1 echo "$self_name: expected SRC_DIR (use --src-dir=SRC_DIR)"
fi

rm -f state/unpack.result
rm -rf ${src_dir}

set -x
tar xf ${tarball_path} 2>&1 | tee log/tar.log
err=$?
set +x

if [[ ${err} -eq 0 ]]; then
    if [[ -d ${tarball_unpack_dir} ]]; then
        if [[ ${tarball_unpack_dir} != ${src_dir} ]]; then
            rm -rf ${src_dir}
            mv ${tarball_unpack_dir} ${src_dir}
        fi
    else
        echo -n "err: expected unpack TARBALL_PATH [${tarball_path}] to get UNPACKDIR [${tarball_unpack_dir}]"
        exit 1
    fi

     if [[ -d ${src_dir} ]]; then
         echo -n 'ok ' > state/unpack.result
         echo ${src_dir} >> state/unpack.result
         exit 0
     else
         echo "err: expected unpack TARBALL_PATH [${tarball_path}] to get SRC_DIR [${src_dir}]" > state/unpack.reseult
         exit 1
     fi
else
    echo "err: failed to unpack [${tarball_path}]" > state/unpack.result
    exit 1
fi

# end unpack-tarball.sh
