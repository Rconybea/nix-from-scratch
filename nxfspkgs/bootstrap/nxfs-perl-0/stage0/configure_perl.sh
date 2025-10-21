#!/bin/bash
# reminder: perl builds in source directory

set -euo pipefail

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --src-dir=SRCDIR --build-dir=BUILDDIR --configure-exec=CONFIGEXEC --configure-script=CONFIGURE --cflags=CFLAGS --ldflags=LDFLAGS --configure-extra-args=ARGS"
}

srcdir=
cflags=
ldflags=
prefix=
local_prefix=
version_major_minor=

while [[ $# > 0 ]]; do
    case "$1" in
        --src-dir=*)
            srcdir=${1#*=}
            ;;
        --cflags=*)
            cflags=${1#*=}
            ;;
        --ldflags=*)
            ldflags=${1#*=}
            ;;
        --prefix=*)
            prefix=${1#*=}
            ;;
        --local-prefix=*)
            local_prefix=${1#*=}
            ;;
        --version-major-minor=*)
            version_major_minor=${1#*=}
            ;;
        *)
            2>&1 echo "$self_name: unexpected argument [$1]"
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z "${prefix}" ]]; then
    2>&1 echo "$self_name: expected PREFIX [use --prefix=PREFIX]"
    exit 1
fi

if [[ -z "${srcdir}" ]]; then
    2>&1 echo "$self_name: expected SRCDIR [use --src-dir=SRCDIR]"
    exit 1
fi

if [[ -z "${cflags}" ]]; then
    2>&1 echo "$self_name: expected CFLAGS [use --cflags=CFLAGS]"
    exit 1
fi

if [[ -z "${ldflags}" ]]; then
    2>&1 echo "$self_name: expected LDFLAGS [use --ldflags=LDFLAGS]"
    exit 1
fi

if [[ -z "${version_major_minor}" ]]; then
    2>&1 echo "$self_name: expected VERSION_MAJOR_MINOR [use --version-major-minor=VERSION_MAJOR_MINOR]"
    exit 1
fi

pushd ${srcdir}

perldir=${prefix}/lib/perl5/${version_major_minor}

set -x

#sh Configure -des -Dprefix=${prefix} -Dccflags="${cflags}" -Dldflags="${ldflags}" -Dvendorprefix=${prefix} -Duseshrplib -Dprivlib=${perldir}/core_perl -Darchlib=${perldir}/core_perl -Dsitelib=${perldir}/site_perl -Dsitearch=${perldir}/site_perl -Dvendorlib=${perldir}/vendor_perl -Dvendorarch=${perldir}/vendor_perl

# -Uuselocale: disable locale support (assume we don't need during bootstrap)
#
sh Configure -des -Dprefix=${prefix} -Dccflags="${cflags}" -Dldflags="${ldflags}" \
   -Dlocincpth=${local_prefix}/include -Dloclibpth=${local_prefix}/lib -Dlibpth="${local_prefix}/lib /usr/lib" \
   -Dvendorprefix=${prefix} -Duseshrplib \
   -Dprivlib=${perldir}/core_perl -Darchlib=${perldir}/core_perl -Dsitelib=${perldir}/site_perl \
   -Dsitearch=${perldir}/site_perl -Dvendorlib=${perldir}/vendor_perl -Dvendorarch=${perldir}/vendor_perl \
   -Uuselocale

set +x
