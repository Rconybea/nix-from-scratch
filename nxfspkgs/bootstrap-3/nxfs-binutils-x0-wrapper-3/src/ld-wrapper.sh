#! @bash@
#
# Script to provide a version of ld
# that links using a nix-store-located libc + ELF interpreter.
#
# Need this as part of nxfs bootstrap, with {glibc, binutils}
# located in different directories.
#
# Can use NXFS_SYSROOT_DIR to refer to a different glibc directory.
# Will need this if you  want to use this wrapper in glibc build,
# (though perhaps moot since we don't use this wrapper in nxfs-glibc-stage1-2).
#

binutils=@binutils@
glibc=@glibc@

if [[ -z "${NXFS_SYSROOT_DIR}" ]]; then
    NXFS_SYSROOT_DIR=${glibc}
fi

if [[ $# -eq 1 ]] && ([[ "$1" == -v ]] || [[ "$1" == --version ]]); then
    # ld has carveout when given '-v' with no other arguments
    #  ${unwrapped_ld} -v
    # prints a message and return 0 exit code.
    # Make sure we preserve that behavior
    #
    ${binutils}/bin/ld -v
elif [[ $# -eq 1 ]] && [[ "$1" == -v ]]; then
    # similar carveout for
    #  ${unwrapped_ld} --help
    #
    ${binutils}/bin/ld --help
else
    ${binutils}/bin/ld "${@}" -L ${NXFS_SYSROOT_DIR}/lib -rpath ${NXFS_SYSROOT_DIR}/lib -dynamic-linker ${NXFS_SYSROOT_DIR}/lib/ld-linux-x86-64.so.2
fi
