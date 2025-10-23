#! @bash@
#
# Wrapped version of cpp.
#
# Setup within nix is bespoke relative to vanilla linux distribution:
# 1. No common /usr/lib or /lib directory.
#    Instead {glibc, gcc} are in separate dedicated directories
# 2. This means we need additional flags to tell cpp where to find gcc and glibc headers.
#

unwrapped_cpp=@unwrapped_cpp@
gcc=@gcc@
glibc=@glibc@
target_tuple=@target_tuple@
gcc_version=@gcc_version@

# NOTE: not sure if this is needed for cpp, but certainly shouldn't be harmful
PATH=${gcc}/bin:$PATH

if [[ $# -eq 1 ]] && [[ "$1" == '-v' ]]; then
    # gcc has carveout when given '-v' with no other arguments:
    #   ${unwrapped_gcc} -v
    # prints a message and returns 0 exit code,
    # but won't preserve that behavior if we also pass linker arguments
    #
    ${unwrapped_cpp} -v
else
    # call native cpp with additional flags:
    #   -isystem ${glibc}/include            standard C library headers
    #   -isystem ${gcc}/include              compiler-specific headers (e.g. GCC stddef.h, stdint.h)
    #   -isystem ${gcc}/lib/gcc/.../include  GCC internal headers
    #   -idirafter ${glibc}/include          standard C library headers, last resort
    #
    ${unwrapped_cpp} "${@}" \
                     -isystem ${glibc}/include \
                     -isystem ${gcc}/include \
                     -isystem ${gcc}/lib/gcc/${target_tuple}/${gcc_version}/include \
                     -idirafter ${glibc}/include
fi
