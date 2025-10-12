#!/bin/bash
#
# BOOTSTRAP REMARKS:
# At this point in bootstrap, we have
# - nix store containing result of essential fixed-output derivations.
#   these derivations were built outside the nix store and refer to paths
#   that aren't accessible during nix-build.
# - we need to patch toolchain first, since libc from the patched toolchain
#   is the desired target for all the other stage-1 packages.
# - whenever we refer to a stage-0 executable, we will need to
#   R1. explicitly invoke the dynamic loader ${toolchain}/bin/ld.so
#   R2. explicitly supply toolchain library path ${toolchain}/lib
# - the bash instance running this script is also in an impaired state:
#   searching PATH for executables doesn't work
#   (possibly because requires R1 and R2 prevent bash recognizing
#    executables).  Instead have to:
#   R3. give full path to an executable
# - as we progressively introduce patched stage-1 packages,
#   we can retire the explicit invocation

set -euo pipefail

echo
echo "host_tuple=${host_tuple}"
echo "gcc_version=${gcc_version}"
echo "bash=${bash}"
echo "toolchain=${toolchain}"
echo "gawk=${gawk}"
echo "gnused=${gnused}"
echo "gnutar=${gnutar}"
echo "coreutils=${coreutils}"
echo "patchelf=${patchelf}"
echo "redirect_elf_file_0=${redirect_elf_file_0}"
echo "TMP=${TMP}"
echo

# not feasible here, see R3 above
#export PATH=${gnused}/bin:${gnutar}/bin:${coreutils}/bin:${patchelf}/bin

# see R3 above
#
mkdir=${coreutils}/bin/mkdir
cat=${coreutils}/bin/cat
chmod=${coreutils}/bin/chmod
cp=${coreutils}/bin/cp
ls=${coreutils}/bin/ls
rm=${coreutils}/bin/rm
tar=${gnutar}/bin/tar
patchelf=${patchelf}/bin/patchelf
sed=${gnused}/bin/sed
gawk=${gawk}/bin/gawk

set -x

# ----------------------------------------------------------------
# helper bash scripts, including invoke0

source "${redirect_elf_file_0}"

invoke0 ${mkdir} ${out}

# ----------------------------------------------------------------
# local variables

nxfs_toolchain_prefix=$(invoke0 ${cat} ${toolchain}/nix-support/nxfs-toolchain-prefix)
dynamic_linker_relpath=lib/$(invoke0 ${cat} ${toolchain}/nix-support/dynamic-linker-name)

target_interpreter=${out}/${dynamic_linker_relpath}
target_runpath=${out}/lib

staging=${TMP}

# ----------------------------------------------------------------
# verify initial paths

echo "stage0 toolchain dir: ${toolchain}"

# ----------------------------------------------------------------
# copy to temporary staging dir.

invoke0 ${mkdir} -p ${staging}

(cd ${toolchain} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${staging}))

# ----------------------------------------------------------------
# modify {interpreter, RUNPATH} for toolchain artifacts
# to point to nxfspkgs/bootstrap-1 nix/store locations
# (that will be created by this builder)

invoke0 ${chmod} u+w ${staging}

invoke0 ${ls} -ld ${staging}/${libc_relpath}

invoke0 ${chmod} u+w ${staging}/lib
invoke0 ${chmod} u+w ${staging}/${libc_relpath}

# set dynamic linker for libc.so.6 to nix/store location
invoke0 ${patchelf} --set-interpreter ${target_interpreter} ${staging}/${libc_relpath}

invoke0 ${chmod} u-w ${staging}/${libc_relpath}

# libc.so (not libc_relpath, that's lib/libc.so.6) is a short script with a line like:
#  GROUP ( /path/to/lib/libc.so.6 /path/to/lib/libc_nonshared.a AS_NEEDED (/path/to/lib/ld-linux-x86-64.so.2 ) )
# we want /path/to/lib replaced by ${out}/lib
#
invoke0 ${sed} -i -e s:${nxfs_toolchain_prefix}/lib:${out}/lib:g ${staging}/${libc_nv_relpath}

# libm.so is a short linker script with a line like:
#  GROUP ( /path/to/libm.so.6 AS_NEEDED ( /path/to/libmvec.so.1 ) )
# we want /path/to/lib replaced by ${out}/lib
#
invoke0 ${sed} -i -e s:${nxfs_toolchain_prefix}/lib:${out}/lib:g ${staging}/${libm_nv_relpath}

# libm.a is also a short linker script, similar to libm.so
#
invoke0 ${sed} -i -e s:${nxfs_toolchain_prefix}/lib:${out}/lib:g ${staging}/${libm_static_relpath}

# bash globbing doesn't work here.  defer this until we have a patched bash
#
## remove all the .la files (produced by libtool).
## They're not needed on modern linux + invalidated by changing filesystem location.
## If they turned out to be important, we'd have to laboriously update them anyway
#invoke0 ${rm} ${out}/lib/*.la

invoke0 ${chmod} u+w ${staging}/lib/gcc
invoke0 ${chmod} u+w ${staging}/lib/gcc/${host_tuple}

# remove spec file
#   (see nix-from-scratch/toolchain/toolchain/tools/capturespecs.sh,
#    created by nix-from-scratch/toolchain/toolchain/toolchain-configure.sh)
# the spec file causes {gcc, g++} to automatically insert external toolchain location
# into RUNPATH for libraries and executables. This usually has no effect within a nix build,
# since in that context only paths inside the nix store are accessible.
# That said, it's at best misleading.
#
invoke0 ${rm} ${staging}/lib/gcc/${host_tuple}/specs

invoke0 ${chmod} u-w ${staging}/lib/gcc/${host_tuple}
invoke0 ${chmod} u-w ${staging}/lib/gcc
invoke0 ${chmod} u-w ${staging}/lib

# ----------------------------------------------------------------

invoke0 ${chmod} u+w ${staging}/bin

# bin/ldd is a bash script.
# modify ldd to point to nix-store dynamic linker.
# (not strictly needed for bootstrap, but gets nix-store ldd to correctly
#  refer to the dynamic linker copied to nix/store)
#
invoke0 ${sed} -i -e 's:^RTLDLIST=.*$:RTLDLIST='${target_interpreter}':' ${staging}/bin/ldd
# interesting iff we build locales when preparing toolchain (before importing into nix).
# in any case only effective during nix bootstrap sequence
#
invoke0 ${sed} -i -e 's:^TEXTDOMAINDIR=.*$:TEXTDOMAINDIR='${out}/share/locale':' ${staging}/bin/ldd

invoke0 ${chmod} u+w ${staging}/${host_tuple}
invoke0 ${chmod} u+w ${staging}/${host_tuple}/bin
invoke0 ${chmod} u+w ${staging}/libexec/gcc/${host_tuple}/${gcc_version}

for dir in ${staging}/bin ${staging}/${host_tuple}/bin ${staging}/libexec/gcc/${host_tuple}/${gcc_version}; do
    echo "consider directory [${dir}]"
    for file in ${dir}/*; do
        echo "consider [${file}]"

        if [[ -L ${file} ]]; then
            # in particular: must skip symlink bin/ld.so -> ../lib/ld-linux-x86-64.so.2,
            # it's statically linked -> doesn't need patching,
            # and in any case patchelf will mortally damage it.
            #
            echo "skip symlink [${file}]"
        elif [[ -f ${file} ]]; then
            redirect_elf_file_0 ${file} ${target_interpreter} ${target_runpath}
        else
            echo "skip non-regular-file [${file}]"
        fi
    done
done

invoke0 ${chmod} u-w ${staging}/libexec/gcc/${host_tuple}/${gcc_version}
invoke0 ${chmod} u-w ${staging}/${host_tuple}/bin
invoke0 ${chmod} u-w ${staging}/${host_tuple}
invoke0 ${chmod} u-w ${staging}/bin

# ----------------------------------------------------------------
# Copy to final destination
#
final=${out}

(cd ${staging} && (invoke0 ${tar} cf - . | invoke0 ${tar} xf - -C ${final} ))

# ----------------------------------------------------------------
# Get gcc to dump spec file, so that downstream can explicitly refer to it.
# It appears that imported gcc still refers to original spec file location.
# This is problematic because we curated a gcc spec file that sets up custom
# RUNPATH and dynamic linker.  Want to definitively exclude that
# spec file being used during nix store bootstrap.
#
# Can observe behavior:
#   gcc -v
# Can insist on spec file:
#   gcc -specs path/to/specs

invoke0 ${chmod} u+w ${out}
invoke0 ${chmod} u+w ${out}/lib/gcc/${host_tuple}

specfile=${out}/lib/gcc/${host_tuple}/specs

invoke0 ${out}/bin/gcc -dumpspecs > ${TMP}/specs

invoke0 ${cat} >> ${TMP}/specs <<EOF
*cpp:
+ -nostdinc -isystem ${out}/lib/gcc/${host_tuple}/${gcc_version}/include -isystem ${out}/include/c++/14.2.0 -isystem ${out}/include/c++/${gcc_version}/${host_tuple} -isystem ${out}/include/c++/${gcc_version}/backward -isystem ${out}/include

*cc1:
+ -nostdinc

*cc1plus:
+ -nostdinc
EOF

invoke0 ${cp} ${TMP}/specs ${specfile}

invoke0 ${chmod} u-w ${out}/lib/gcc/${host_tuple}

invoke0 ${chmod} u+w ${out}/nix-support

invoke0 ${rm} -f ${out}/nix-support/gcc-specs
invoke0 ${cp} ${TMP}/specs ${out}/nix-support/gcc-specs

invoke0 ${chmod} u-w ${out}/nix-support
