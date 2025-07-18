#!/bin/bash
#
# Promise:
# 1. state/fetch.result contains:
#    - <TARBALL_PATH> on successful download
#    - error message if download failed
# 2. writes [log/wget.log]
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --archive-dir=ARCHIVE_DIR --url=URL --tarball-path=TARBALL [--fetchresult=FETCHRESULT] [--fetch-extra-args=FETCHARGS]"
}

ARCHIVE_DIR=
url=
tarball_path=
fetchresult=state/fetch.result
fetch_extra_args=

while [[ $# > 0 ]]; do
    case "$1" in
        --archive-dir=*)
            ARCHIVE_DIR=${1#*=}
            ;;
        --url=*)
            url="${1#*=}"
            ;;
        --tarball-path=*)
            tarball_path="${1#*=}"
            ;;
        --fetchresult=*)
            fetchresult="${1#*=}"
            ;;
        --fetch-extra-args=*)
            fetch_extra_args="${1#*=}"
            ;;
        *)
            >&2 echo -n "usage"
            >&2 usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${ARCHIVE_DIR} ]]; then
    2>&1 echo "$self_name: expected ARCHIVE_DIR (use --archive-dir=ARCHIVE_DIR)"
fi

if [[ ! -d ${ARCHIVE_DIR} ]]; then
    2>&1 echo "$self_name: expected directory: [${ARCHIVE_DIR}]"
fi

if [[ -z ${url} ]]; then
    2>&1 echo "$self_name: expected URL (use --url=URL)"
fi

if [[ -z ${tarball_path} ]]; then
    2>&1 echo "$self_name: expected TARBALL (use --tarball-path=TARBALL)"
fi

rm -f ${fetchresult}
rm -f ${tarball_path}

(cd ${ARCHIVE_DIR} && wget --output-document=${tarball_path} ${fetch_extra_args} ${url}) 2>&1 | tee log/wget.log
err=$?

if [[ ${err} -eq 0 && -f ${tarball_path} && -s ${tarball_path} ]]; then
    echo -n 'ok ' > ${fetchresult}
    echo ${tarball_path} >> ${fetchresult}
    exit 0
else
    echo "err: expected wget to create non-empty [${tarball_path}]" > ${fetchresult}
    exit 1
fi

# end fetch-tarball.sh
