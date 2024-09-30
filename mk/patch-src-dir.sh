#!/bin/bash
#
# Promise:
# 1. state/patch.result contains:
#    a. sha256 of source tarball
#    b. sha256 of patch script    (if present)
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --tarball-path=TARBALL --src-dir=SRC_DIR"
}

src_dir=
# true iff no patch script / patch file given
noop_flag=1
patch_script=

while [[ $# > 0 ]]; do
    case "$1" in
        --src-dir=*)
            src_dir=${1#*=}
            ;;
        --patch-script=*)
            patch_script=${1#*=}
            noop_flag=0
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${src_dir} ]]; then
    2>&1 echo "$self_name: expected SRC_DIR (use --src-dir=SRC_DIR)"
fi

if [[ ! -d ${src_dir} ]]; then
    2>&1 echo "$self_name: SRC_DIR: expected directory: [${src_dir}]"
fi

set -x
cat state/expected.sha256 > state/tmp.patch.sha256
set +x

if [[ -n "${patch_script}" ]]; then
    set -x
    sha256sum ${patch_script} >> state/tmp.patch.sha256
    set +x
fi

# (re)patch if err!=0
err=0

if [[ -f state/done.patch.sha256 ]]; then
    set -x
    diff state/tmp.patch.sha256 state/done.patch.sha256
    set +x
    err=$?
else
    err=1
fi

if [[ $err -eq 0 ]]; then
    # looks like patch already applied -> should already have [state/patch.result]
    rm -f state/tmp.patch.sha256
    if [[ ! -f state/patch.result ]]; then
        # control here: manually deleting state/unpack.result for eacmple
        echo "ok " > state/patch.result
        cat state/done.patch.sha256 >> state/patch.result
    fi
else  # something changed -> will modify [state/patch.result]
    set -x
    err=0
    if [[ -n ${patch_script} ]]; then
        (cd ${src_dir} && ../${patch_script})
        err=$?
    fi
    if [[ ${err} -eq 0 ]]; then
        mv state/tmp.patch.sha256 state/done.patch.sha256
        echo "ok " > state/patch.result
        cat state/done.patch.sha256 >> state/patch.result
    else
        2>&1 echo "patch-src-dir: attempt to apply patch [${patch_script}] failed!"
        rm -f state/tmp.patch.sha256
        # invalidate any prior patch result
        rm -f state/patch.result
        # must redo tar before trying to patch again
        rm -f state/unpack.result
        exit 1
    fi
    set +x;
fi

# end patch-src-dir.sh
