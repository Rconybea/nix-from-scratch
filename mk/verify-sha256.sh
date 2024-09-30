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
    echo "$self_name"
}

set -x
rm -f state/verify.tmp state/verify.err
sha256sum --check state/expected.sha256 2> state/verify.err
err=$?
set +x

if [[ $err -eq 0 ]]; then
    set -x
    echo -n "ok " > state/verify.tmp
    cat state/expected.sha256 >> state/verify.tmp
    verified=1
    set +x
else
    set -x
    echo -n "err " > state/verify.tmp
    cat state/verify.err >> state/verify.tmp
    verified=0
    set +x
fi

rm -f state/verify.err

if [[ -f state/verify.result ]] && grep '^ok' state/verify.result; then
    set -x
    diff -q state/verify.tmp state/verify.result
    set +x
    err=$?
else
    # no prior result to compare
    err=1
fi

if [[ $err -ne 0 ]]; then
    set -x
    mv -f state/verify.tmp state/verify.result
    set +x
else
    set -x
    rm state/verify.tmp
    set +x
fi

if [[ ${verified} -eq 0 ]]; then
    exit 1
fi
