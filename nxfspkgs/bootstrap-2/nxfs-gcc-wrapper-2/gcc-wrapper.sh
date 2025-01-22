#! @bash@
#
# Script to provide a version of gcc
# that build executables that use nix-store-locaated libc + ELF interpreter.
#
# Need this to adopt a gcc that was originally compiled outside nix store,
# and by defult produces executables that assume /lib64

unwrapped_gcc=@unwrapped_gcc@
sysroot=@sysroot@

#2> echo "nxfs: gcc-wrapper calling:"
#2> echo "nxfs:   ${unwrapped_gcc} -Wl,--rpath=${sysroot}/lib -Wl,--dynamic-linker=${sysroot}/lib/ld-linux-x86-64.so.2" "${@}"

if [[ $# -eq 1 ]] && [[ "$1" == '-v' ]]; then
    # gcc has carveout when given '-v' with no other arguments:
    #   ${unwrapped_gcc} -v
    # prints a message and returns 0 exit code,
    # but won't preserve that behavior if we also pass linker arguments
    #
    ${unwrapped_gcc} -v
else
    ${unwrapped_gcc} -Wl,-rpath=${sysroot}/lib -Wl,-dynamic-linker=${sysroot}/lib/ld-linux-x86-64.so.2 "${@}"
fi
