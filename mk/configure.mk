# Require:
# - including makefile provides:
#     TOP_DIR, PREFIX, srcdir, builddir, cflags, cppflags, ldflags, configure_extra_args,
#     pre_configure_hook  
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

# specify --configure-exec or --configure-script, but not both.
#
# --configure-script=SCRIPT -> SCRIPT that resides in package source directory,
#                              and will be invoked there (e.g. path/to/src/configure)
# --configure-exec=EXEC -> EXEC that resides in host environment (e.g. cmake)
state/config.result $(builddir): state/patch.result
	mkdir -p $(builddir)
	($(TOP_DIR)/scripts/configure-autotools.sh \
       --prepend-to-path="$(prepend_to_path)" \
       --pre-configure-hook="$(pre_configure_hook)" \
       --post-configure-hook="$(post_configure_hook)" \
       --configure-exec=$(configure_exec) \
	   --configure-script=$(configure_script) \
       --prefix=$(PREFIX) --src-dir=$(srcdir) --build-dir=$(builddir) \
       --cflags="$(cflags)" --cppflags="$(cppflags)" --ldflags="$(ldflags)" \
       --configure-extra-args="$(configure_extra_args)") 2>&1 | tee $(THIS_DIR)/log/config.log

.PHONY: config
config: state/config.result

