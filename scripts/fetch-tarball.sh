#!/bin/bash
#
# Promise:
# 1. state/fetch.result (or FETCHRESULT) contains:
#    - <TARBALL_PATH> on successful download
#    - error message if download failed
# 2. writes [log/wget.log]
# 3. if --noclobber will avoid duplicate fetch when non-empty ARCHIVE_DIR/TARBALL exists
#
# Note that the same ARCHIVE/TARBALL can be referenced from multiple locations.

self_name=$(basename ${0})

usage() {
    echo "$self_name: --archive-dir=ARCHIVE_DIR --url=URL --tarball-path=TARBALL"
    echo "            [--fetchresult=FETCHRESULT] [--fetch-extra-args=FETCHARGS] [--noclobber]"
}

ARCHIVE_DIR=
url=
tarball_path=
fetchresult=state/fetch.result
fetch_extra_args=
noclobber=

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
        --noclobber)
            noclobber=1
            ;;
        *)
            >&2 echo "error: unexpected argument [$1]"
            >&2 echo -n "usage"
            >&2 usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${ARCHIVE_DIR} ]]; then
    2>&1 echo "$self_name: expected ARCHIVE_DIR (use --archive-dir=ARCHIVE_DIR)"
    echo "err: expected ARCHIVE_DIR (use --archive-dir=ARCHIVE_DIR)" > ${fetchresult}
    exit 1
fi

if [[ ! -d ${ARCHIVE_DIR} ]]; then
    2>&1 echo "$self_name: expected directory: [${ARCHIVE_DIR}]"
    echo "err: expected directory [${ARCHIVE_DIR}]" > ${fetchresult}
    exit 1
fi

if [[ -z ${tarball_path} ]]; then
    2>&1 echo "$self_name: expected TARBALL (use --tarball-path=TARBALL)"
    echo "err: expected TARBALL (use --tarball-path=TARBALL)" > ${fetchresult}
    exit 1
fi

if [[ -z ${url} ]]; then
    2>&1 echo "$self_name: expected URL (use --url=URL)"
    echo "err: [$(basename ${tarball_path})] expected URL (use --url=URL)" > ${fetchresult}
    exit 1
fi

rm -f ${fetchresult}

if [[ -n ${noclobber} ]]; then
    if [[ -s ${tarball_path} ]]; then
        echo -n 'ok ' > ${fetchresult}
        echo ${tarball_path} >> ${fetchresult}
        exit 0
    else
        # fall through to wget below
        :
    fi
fi

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
