# Require:
# - including makefile provides TOP_DIR, PREFIX, srcdir, builddir, cflags, ldflags
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

state/config.result $(builddir): state/patch.result
	$(TOP_DIR)/mk/configure-autotools.sh \
       --prefix=$(PREFIX) --src-dir=$(srcdir) \
       --build-dir=$(builddir) --cflags="$(cflags)" --ldflags="$(ldflags)"

.PHONY: config
config: state/config.result
