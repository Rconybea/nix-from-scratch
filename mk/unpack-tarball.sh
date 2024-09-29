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
src_dir=

while [[ $# > 0 ]]; do
    case "$1" in
        --src-dir=*)
            src_dir=${1#*=}
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

if [[ -z ${src_dir} ]]; then
    2>&1 echo "$self_name: expected SRC_DIR (use --src-dir=SRC_DIR)"
fi

set -x
rm -f state/unpack.result
rm -f ${src_dir}

tar xf ${tarball_path} 2>&1 | tee log/tar.log
set +x
err=$?

if [[ ${err} -eq 0 ]]; then
     if [[ -d ${src_dir} ]]; then
         set -x
         echo -n 'ok ' > state/unpack.result
         echo ${src_dir} >> state/unpack.result
         exit 0
     else
         set -x
         echo "err: expected unpack TARBALL_PATH [${tarball_path}] to get SRC_DIR [${src_dir}]" > state/unpack.reseult
         exit 1
     fi
else
    set -x
    echo "err: failed to unpack [${tarball_path}]" > state/unpack.result
    exit 1
fi

# end unpack-tarball.sh
