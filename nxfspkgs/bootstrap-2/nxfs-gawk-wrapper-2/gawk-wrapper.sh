#!@bash_program@
#
# Script to provide a version of gawk that has working
# '|' feature inside a chroot nix build,
# when linked against glibc imported from outside nix.
#

LD_PRELOAD=@execve_preload@/lib/libnxfs_redirect_execve.so @gawk_program@ "${@}"
