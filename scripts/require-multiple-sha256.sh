#!/bin/bash
#
# Promise:
# 1. state/expected.sha256 looks like
#      <SHA256-1> <TARBALL-1>
#      <SHA256-2> <TARBALL-2>
#      ...
# 2. state/expected.sha256 file modification time preserved
#    when contents did not change
#

set -euo pipefail

self_name=$(basename ${0})

usage() {
    cat <<EOF
$self_name: --archive-dir=ARCHIVE_DIR SHA:TARBALL...
EOF
}

archive_dir=
pairs=()

while [[ $# > 0 ]]; do
    case $1 in
        --archive-dir=*)
            archive_dir=${1#*=}
            ;;
        --*)
            echo "error: ${self_name}: unexpected argument [$1]"
            usage
            exit 1
            ;;
        *)
            pairs+=(${1})
            ;;
    esac

    shift
done

echo "archive_dir=$archive_dir"

tarballs=()

cat /dev/null > state/tmp.sha256

for i in ${pairs[@]}; do
    sha=${i%:*}
    tarball=${i#*:}
    echo "i=$i sha=$sha tarball=$tarball"

    echo "$sha $archive_dir/$tarball" >> state/tmp.sha256

    tarballs+=($archive_dir/$tarball)
done

set -x
sha256sum ${tarballs[@]} > state/actual.sha256

echo "state/tmp.sha256:"
cat state/tmp.sha256

if [ ! -f state/expected.sha256 ] || ! diff state/tmp.sha256 state/expected.sha256; then
    mv state/tmp.sha256 state/expected.sha256
else
    rm state/tmp.sha256
fi
