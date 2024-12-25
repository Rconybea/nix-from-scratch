#! @bash@
#
# Script to provide a version of gcc
# that build executables that use nix-store-locaated libc + ELF interpreter.
#
# Need this to adopt a gcc that was originally compiled outside nix store,
# and by defult produces executables that assume /lib64

unwrapped_gcc=@unwrapped_gcc@
sysroot=@sysroot@

2> echo "gcc-wrapper calling:"
2> echo "  ${unwrapped_gcc} -Wl,--rpath=${sysroot}/lib -Wl,--dynamic-linker=${sysroot}/lib/ld-linux-x86-64.so.2" "${@}"

${unwrapped_gcc} -Wl,-rpath=${sysroot}/lib -Wl,-dynamic-linker=${sysroot}/lib/ld-linux-x86-64.so.2 "${@}"
