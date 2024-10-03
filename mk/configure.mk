# Require:
# - including makefile provides:
#     TOP_DIR, PREFIX, srcdir, builddir, cflags, ldflags, configure_extra_args,
#     pre_configure_hook  
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

state/config.result $(builddir): state/patch.result
	mkdir -p $(builddir)
	$(TOP_DIR)/mk/configure-autotools.sh \
       --pre-configure-hook="$(pre_configure_hook)" \
	   --configure-script=$(configure_script) \
       --prefix=$(PREFIX) --src-dir=$(srcdir) --build-dir=$(builddir) \
       --cflags="$(cflags)" --ldflags="$(ldflags)" \
       --configure-extra-args="$(configure_extra_args)"


.PHONY: config
config: state/config.result

