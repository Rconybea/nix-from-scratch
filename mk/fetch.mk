# Require:
# - including makefile provides TOP_DIR, ARCHIVE_DIR, url, tarball_path
#
# Included in per-package Makefiles ($(TOP_DIR)/pkgs/foo/Makefile)
#

# fetch tarball
#
# on success:
# - state/fetch.result holds tarball_path
# on failure:
# - state/fetch.result holds error message
#
$(tarball_path) state/fetch.result: 
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	$(TOP_DIR)/scripts/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(url) --tarball-path=$(tarball_path) "--fetch-extra-args=${fetch_extra_args}" --noclobber

# - noop when $(tarball_path) already established
#   (use `make distclean` to do-over)
#
.PHONY: fetch
fetch: $(tarball_path) state/fetch.result

