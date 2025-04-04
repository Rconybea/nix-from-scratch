#! @bash@
#
# Script to provide a version of gcc
# that build executables that use nix-store-locaated libc + ELF interpreter.
#
# Need this to adopt a gcc that was originally compiled outside nix store,
# and by defult produces executables that assume /lib64

unwrapped_gxx=@unwrapped_gxx@
glibc=@glibc@

if [[ $# -eq 1 ]] && [[ "$1" == '-v' ]]; then
    # gcc has carveout when given '-v' with no other arguments:
    #   ${unwrapped_gcc} -v
    # prints a message and returns 0 exit code,
    # but won't preserve that behavior if we also pass linker arguments
    #
    ${unwrapped_gxx} -v
else
    #>&2 echo "nxfs-gcc-x0-wrapper-3:"
    #>&2 echo "NXFS_SYSROOT_DIR=${NXFS_SYSROOT_DIR}"
    #>&2 echo "CWD=$(pwd)"
    #>&2 echo "PATH=${PATH}"

    ${unwrapped_gxx} -B${glibc}/lib -Wl,-rpath=${glibc}/lib -Wl,-dynamic-linker=${glibc}/lib/ld-linux-x86-64.so.2 "${@}"
fi
