# Require:
# - including makefile provides TOP_DIR, sha256, tarball_path
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

# promise:
# - [state/expected_sha256] consistent with {$(sha256), $(tarball_path)};
#   only updated when contents changed
#   (so [state/expected.sha256] works well as make dependency)
# - exit code 0 iff {expected, actual} match
#
# (reminder: state/fetch.result here needed so that 'make all' in initial state does fetch,
#  since require-sha256 checks that tarball path is present + additionally produces actual sha256)
#
sha256 state/expected.sha256: state/fetch.result
	$(TOP_DIR)/mk/require-sha256.sh --sha256=$(sha256) --tarball-path=$(tarball_path)

state/verify.result: state/expected.sha256 
	$(TOP_DIR)/mk/verify-sha256.sh

# - noop when state/verify.result already established
#   (use `make verifyclean` to do-over)
#
.PHONY: verify
verify: state/verify.result

