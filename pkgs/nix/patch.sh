#!/bin/bash
#

self_name=$(basename ${0})

usage() {
    echo "$self_name: --srcdir=SRCDIR"
}

#src_dir=
#
#while [[ $# > 0 ]]; do
#    case "$1" in
#        --srcdir=*)
#            src_dir=${1#*=}
#            ;;
#        *)
#            usage
#            exit 1
#            ;;
#    esac
#
#    shift
#done
#
#if [[ -z ${src_dir} ]]; then
#    2>&1 echo "error: ${self_name}: expected non-empty SRCDIR"
#    exit 1
#fi

# downgrade switch-related errors to warnings.  Perhaps coming from newer toml11?
set -x

sed -i -e '/^GLOBAL_CXXFLAGS/s:-Werror=suggest-override:-Wsuggest-override:' Makefile
sed -i -e '/^GLOBAL_CXXFLAGS/s:-Werror=switch:-Wswitch:' -e '/^ERROR_SWITCH_ENUM/s:-Werror=switch-enum:-Wswitch-enum:' local.mk

echo 'local.mk:'
egrep 'GLOBAL_CXXFLAGS|ERROR_SWITCH_ENUM' local.mk

echo 'Makefile:'
grep GLOBAL_CXXFLAGS Makefile

