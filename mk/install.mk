# Require:
# - including makefile provides TOP_DIR, builddir
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

.PHONY: install
install:
	$(TOP_DIR)/mk/install-autotools.sh --build-dir=$(builddir)

