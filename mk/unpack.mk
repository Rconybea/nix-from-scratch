# Require:
# - including makefile provides TOP_DIR, tarball_path, srcdir
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

state/unpack.result: state/verify.result 
	$(TOP_DIR)/mk/unpack-tarball.sh --tarball-path=$(tarball_path) --tarball-unpack-dir=$(unpackdir) --src-dir=${srcdir}

.PHONY: unpack
unpack: state/unpack.result


