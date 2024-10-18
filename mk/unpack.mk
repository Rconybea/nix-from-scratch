# Require:
# - including makefile provides TOP_DIR, tarball_path, srcdir
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

state/unpack.result: state/verify.result 
	echo $(name) > state/package-version
	$(TOP_DIR)/scripts/unpack-tarball.sh --tarball-path=$(tarball_path) --tarball-unpack-dir=$(unpackdir) --src-dir=${srcdir} --unpack-exec=$(unpack_exec) --unpack-args=$(unpack_args)

.PHONY: unpack
unpack: state/unpack.result

