Wrapper for stage2.1 binutils

Primary problem is pointing to separate sysroot for libc etc.
When we build gcc (see nxfs-gcc-stage1-2) we solve for that with
suitable arguments to ./configure.

The {gcc, g++} wrappers {nxfs-gcc, nxfs-g++} don't need this,
since they forward suitable linker arguments to unwrapped binutils.

However in combined {gcc, libstdc++} build, when top-level build
verifies that just-compiled xgcc works, it winds up invoking ld
without forwarding the additional linker flags we supplied to toplevel configure
(--with-stage1-ld-flags, --with-boot-ldflags, LDFLAGS environment var);
in turn causes libstdc++v3/configure to believe xgcc can't build executables.

Remarks:
1. in nxfs-gcc-stage1-2 this isn't a problem, since libstdcxx disabled.
2. in nxfs-libstdcxx-stage2-2 we're building with wrapped gcc instead of xgcc,
   so the can-executables-build test passes using wrapped gcc.
