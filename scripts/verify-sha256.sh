#!/bin/bash
#
# Require:
# 1. [state/expected.sha256] contains expected sha256 for tarball
#
# Promise:
# 2. [state/verify.result] looks like:
#    2a. succes:
#          ok <SHA256> <TARBALL>
#        when tarball verified against expected sha256
#    2b. failure:
#          err <message>
#        when sha256 did not match expected value
# 3. preserves [state/verify.result] file modification time
#    when contents did not change

self_name=$(basename ${0})

usage() {
    echo "$self_name [--verifyresult=VERIFYRESULT]"
}

verifyresult=state/verify.result

while [[ $# > 0 ]]; do
    case "$1" in
        --verifyresult=*)
            verifyresult="${1#*=}"
            ;;
        *)
            >&2 echo -n "usage"
            >&2 usage
            exit 1
            ;;
    esac

    shift
done

set -x
rm -f state/verify.tmp state/verify.err
sha256sum --check state/expected.sha256 > state/verify.err
set +x
err=$?

if [[ $err -eq 0 ]]; then
    verified=1
else
    verified=0
fi

(paste -d ' ' state/expected.sha256 state/verify.err | awk '{print $4, $1, $2}') > state/verify.tmp

#echo "state/verify.err:"
#cat state/verify.err
#echo "state/verify.tmp:"
#cat state/verify.tmp

rm -f state/verify.err

if [[ -f ${verifyresult} ]] && grep '^ok' ${verifyresult}; then
    diff -q state/verify.tmp ${verifyresult}
    err=$?
else
    # no prior result to compare,  or prior result an error
    err=1
fi

if [[ $err -ne 0 ]]; then
    mv -f state/verify.tmp ${verifyresult}
else
    rm state/verify.tmp
fi

if [[ ${verified} -eq 0 ]]; then
    mv ${verifyresult} state/verify.err
    exit 1
fi
