# Require:
# - including makefile provides TOP_DIR, srcdir, patch_script
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

state/patch.result: state/unpack.result $(patch_script)
	$(TOP_DIR)/scripts/patch-src-dir.sh --src-dir=$(srcdir) --patch-script=$(patch_script)

.PHONY: patch
patch: state/patch.result

