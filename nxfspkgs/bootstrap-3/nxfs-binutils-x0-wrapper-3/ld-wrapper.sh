#! @bash@
#
# Script to provide a version of ld
# that links using a nix-store-located libc + ELF interpreter.
#
# Need this as part of nxfs bootstrap, with {glibc, binutils}
# located in different directories.
#
# Can use NXFS_SYSROOT_DIR to refer to a different glibc directory.
# Will need this if you want to use this wrapper in glibc build,

unwrapped_ld=@unwrapped_ld@
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
    ${unwrapped_ld} -v
elif [[ $# -eq 1 ]] && [[ "$1" == --help ]]; then
    # similar carveout for
    #  ${unwrapped_ld} --help
    #
    ${unwrapped_ld} --help
else
    #>&2 echo "nxfs-binutils-xo-wrapper-3:"
    #>&2 echo "NXFS_SYSROOT_DIR=${NXFS_SYSROOT_DIR}"
    #>&2 echo "CWD=$(pwd)"
    #>&2 echo "PATH=${PATH}"

    ${unwrapped_ld} "${@}" -L ${NXFS_SYSROOT_DIR}/lib -rpath ${NXFS_SYSROOT_DIR}/lib -dynamic-linker ${NXFS_SYSROOT_DIR}/lib/ld-linux-x86-64.so.2
fi
