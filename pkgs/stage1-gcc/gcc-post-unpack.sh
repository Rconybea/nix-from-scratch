#!/bin/bash

self_name=$(basename ${0})

usage() {
    echo "$self_name: --prefix=PREFIX --src-dir=SRCDIR"
}

# unpack here
src_dir=
# directory where we fetch tarballs
archive_dir=
# tarball names
gmp=
mpc=
mpfr=

while [[ $# > 0 ]]; do
    case "$1" in
        --archive-dir=*)
            archive_dir=${1#*=}
            ;;
        --gmp=*)
            gmp=${1#*=}
            ;;
        --mpc=*)
            mpc=${1#*=}
            ;;
        --mpfr=*)
            mpfr=${1#*=}
            ;;
        --src-dir=*)
            src_dir=${1#*=}
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    shift
done

if [[ -z ${gmp} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty GMP e.g. ARCHIVE_DIR/gmp-x.y.z.tar.xz"
    exit 1
fi

if [[ -z ${mpc} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty MPC e.g. ARCHIVE_DIR/mpc-x.y.z.tar.gz"
    exit 1
fi

if [[ -z ${mpfr} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty MPFR e.g. ARCHIVE_DIR/mpfr-x.y.z.tar.xz"
    exit 1
fi

if [[ -z ${src_dir} ]]; then
    2>&1 echo "error: ${self_name}: expected non-empty SRCDIR"
    exit 1
fi

set -x

# e.g. gmp-6.3.0.tar.xz -> gmp
gmp_src=${gmp%%.tar.*}
mpc_src=${mpc%%.tar.*}
mpfr_src=${mpfr%%.tar.*}

(cd ${src_dir} && tar xf ${archive_dir}/${gmp}) #gmp-6.3.0.tar.xz
(cd ${src_dir} && mv -v ${gmp_src} gmp)

(cd ${src_dir} && tar xf ${archive_dir}/${mpc})
(cd ${src_dir} && mv -v ${mpc_src} mpc)

(cd ${src_dir} && tar xf ${archive_dir}/${mpfr})
(cd ${src_dir} && mv -v ${mpfr_src} mpfr)
