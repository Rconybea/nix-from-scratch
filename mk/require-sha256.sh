#!/bin/bash
#
# Promise:
# 1. state/expected.sha256 looks like
#      <SHA256> <TARBALL>
# 2. preserves state/expected.sha256 file modification time
#    when contents did not change

self_name=$(basename ${0})

usage() {
    echo "$self_name: --sha256=SHA256 --tarball-path=TARBALL"
}

sha256=
tarball_path=

while [[ $# > 0 ]]; do
    case "$1" in
        --sha256=*)
            sha256="${1#*=}"
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

if [[ -z ${sha256} ]]; then
    2>&1 echo "$self_name: expected SHA256 (use --sha256=SHA256)"
    exit 1
fi

if [[ -z ${tarball_path} ]]; then
    2>&1 echo "$self_name: expected TARBALL (use --tarball-path=TARBALL)"
    exit 1
fi

if [[ ! -f ${tarball_path} ]]; then
    2>&1 echo "$self_name: expected file: TARBALL [${tarball_path}]"
    exit 1
fi

set -x
sha256sum ${tarball_path} > state/actual.sha256
echo "${sha256} ${tarball_path}" > state/tmp.sha256
set +x


if [[ -f state/expected.sha256 ]]; then
    set -x
    diff state/tmp.sha256 state/expected.sha256
    set +x
    err=$?
else
    err=1
fi

if [[ $err -ne 0 ]]; then
    set -x
    mv state/tmp.sha256 state/expected.sha256
    set +x
fi

set -x
rm -f state/tmp.sha256
set +x

# end require-sha256.sh
