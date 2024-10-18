# Require:
# - including makefile provides TOP_DIR, builddir, post_install_hook
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

state/install.result: state/compile.result
	$(TOP_DIR)/scripts/install-autotools.sh --build-dir=$(builddir) --install-exec=$(install_exec) --install-args="$(install_args)"
	$(post_install_hook)
	cp state/compile.result state/install.result

.PHONY: install
install: state/install.result
