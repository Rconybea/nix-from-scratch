# Require:
# - including makefile provides TOP_DIR, builddir
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

state/compile.result: state/config.result
	$(TOP_DIR)/scripts/compile-autotools.sh --build-exec=$(build_exec) --build-args="$(build_args)" --build-dir=$(builddir)

.PHONY: compile
compile: state/compile.result $(builddir)

