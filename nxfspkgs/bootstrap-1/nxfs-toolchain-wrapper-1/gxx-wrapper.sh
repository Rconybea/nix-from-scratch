#! @bash@
#
# Script to provide a version of gcc
# that build executables that use nix-store-locaated libc + ELF interpreter.
#
# Need this to adopt a gcc that was originally compiled outside nix store,
# and by defult produces executables that assume /lib64
#
# See nix-from-scratch/nxfspkgs/build-support/make-stdenv/setup.sh
#

unwrapped_gxx=@unwrapped_gxx@
bintools=@bintools@

export PATH="${bintools}/bin:$PATH"

# Caller won't usually set this,  in which case nxfs-gcc points destination ELF to imported sysroot
# (see nix-from-scratch/nxfspkgs/bootstrap-1/nxfs-sysroot-1).
#
# When building glibc (see nix-from-scratch/nxfspkgs/bootstrap-2/nxfs-glibc-stage1-2) this is counterproductive.
# We need build artifacts to point to output directory.
#
# Can't just use a different wrapper,
# because glibc configure script checks that compiler produces runnable executables.
# Workaround is in glibc build to call configure with NXFS_SYSROOT_DIR empty,  then compile with NXFS_SYSROOT set to ${output}
#
if [[ -z "${NXFS_SYSROOT_DIR}" ]]; then
    NXFS_SYSROOT_DIR=@sysroot@
fi

if [[ $# -eq 1 ]] && [[ "$1" == '-v' ]]; then
    # gcc has carveout when given '-v' with no other arguments:
    #   ${unwrapped_gcc} -v
    # prints a message and returns 0 exit code,
    # but won't preserve that behavior if we also pass linker arguments
    #
    ${unwrapped_gxx} -v
else
    ${unwrapped_gxx} -specs @gcc_specs@ \
                     ${NIX_CFLAGS_COMPILE:-} \
                     -Wl,-rpath=@sysroot@/lib \
                     -Wl,-dynamic-linker=@dynamic_linker@ "${@}"
fi
