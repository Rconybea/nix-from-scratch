#! @bash@
#
# Script to provide a version of gcc
# that build executables that use nix-store-locaated libc + ELF interpreter.
#
# Need this to adopt a gcc that was originally compiled outside nix store,
# and by defult produces executables that assume /lib64

unwrapped_gxx=@unwrapped_gxx@
gcc=@gcc@
glibc=@glibc@

target_tuple=@target_tuple@
cxx_version=@cxx_version@

if [[ -z "${NXFS_SYSROOT_DIR}" ]]; then
    NXFS_SYSROOT_DIR=${glibc}
fi

if [[ $# -eq 1 ]] && [[ "$1" == '-v' ]]; then
    # gcc has carveout when given '-v' with no other arguments:
    #   ${unwrapped_gcc} -v
    # prints a message and returns 0 exit code,
    # but won't preserve that behavior if we also pass linker arguments
    #
    ${unwrapped_gxx} -v
else
    ${unwrapped_gxx} -I${NXFS_SYSROOT_DIR}/include "${@}" -L${gcc}/lib -Wl,-rpath=${gcc}/lib -B${NXFS_SYSROOT_DIR}/lib -Wl,-rpath=${NXFS_SYSROOT_DIR}/lib -Wl,-dynamic-linker=${NXFS_SYSROOT_DIR}/lib/ld-linux-x86-64.so.2
fi
