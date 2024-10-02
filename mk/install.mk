# Require:
# - including makefile provides TOP_DIR, builddir, post_install_hook
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

.PHONY: install
install:
	$(TOP_DIR)/mk/install-autotools.sh --build-dir=$(builddir)
	$(post_install_hook)
