# Require:
# - including makefile provides TOP_DIR, tarball_path, builddir
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

.PHONY: distclean verifyclean unpackclean configclean clean

# unwind to state before fetch.
distclean: verifyclean
	$(TOP_DIR)/scripts/distclean.sh --tarball-path=$(tarball_path) --build-dir=$(builddir)

verifyclean: unpackclean
	rm -f state/verify.result

# unwind to state before src.
# preserves:
# - tarball in $(tarball_path)
# - cksum state
#
unpackclean: configclean
	rm -f state/package-version
	rm -f state/unpack.result
	rm -f state/patch.result
	rm -f state/done.patch.sha256

configclean: clean
	$(TOP_DIR)/scripts/configclean.sh --build-dir=$(builddir)

clean:
	$(TOP_DIR)/scripts/clean.sh --build-dir=$(builddir)

installclean:
	rm -f state/install.result
