#! @bash@
#
# Script to provide a version of gcc
# that build executables that use nix-store-locaated libc + ELF interpreter.
#
# Need this to adopt a gcc that was originally compiled outside nix store,
# which by default produces executables that assume non-reproducible paths like /lib

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
    ${unwrapped_gxx} -specs @gcc_specs@ -Wl,-rpath=${glibc}/lib -Wl,-dynamic-linker=${glibc}/lib/ld-linux-x86-64.so.2 "${@}"
fi
