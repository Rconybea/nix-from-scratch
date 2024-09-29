# Always gets directory containing this Makefile, regardless of cwd
THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# Always root directory for nix-from-scratch (even if not a git repo)
TOP_DIR:=$(realpath $(THIS_DIR)/../..)

# provides:
#   TOP_DIR
#   ARCHIVE_DIR
#   PREFIX           exported
#   PATH             exported
#   PKG_CONFIG_PATH  exported
#
include $(TOP_DIR)/mk/config.mk

# unique package name
name:=m4-1.4.19
# local directory for unpacked source
srcdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://ftp.gnu.org/gnu/m4/$(tarball)
# verify this sha
sha256:=3be4a26d825ffdfda52a56fc43246456989a3630093cced3fbddf4771ee58a70

#
#        /----distclean
#        v
#     (start)
#        |
#        |fetch
#        |
#        |/---verifyclean
#        vv
#       (s1)      [ok: empty state/fetch.result, $(tarball_path), log/wget.log]
#        |
#        |verify
#        |
#        |/---unpackclean
#        vv
#       (s2)      [ok: empty state/verify.result; state/*.sha256]
#        |
#        |unpack
#        v
#       (s3)
#        |
#        |patch
#        v
#       (s4)
#        |
#        |config
#        |
#        |/---clean
#        vv
#       (s5) 
#        |
#        |compile
#        v
#       (s6)
#        |
#        |install
#        v
#     (finish)
#

PHASE:=init fetch verify unpack patch config compile install
COMMANDS:=all sha256 clean unpackclean distclean
.PHONY: $(PHASE) $(COMMANDS)

all: compile

init:
	mkdir -p $(TOP_DIR)/archive
	mkdir -p state
	mkdir -p log

# fetch tarball
#
# on success:
# - state/fetch.result holds tarball_path
# on failure:
# - state/fetch.result holds error message
#
$(tarball_path) init state/fetch.result:
	$(TOP_DIR)/mk/fetch-tarball.sh --archive-dir=$(ARCHIVE_DIR) --url=$(url) --tarball-path=$(tarball_path)

# - noop when $(tarball_path) already established
#   (use `make distclean` to do-over)
#
fetch: $(tarball_path) state/fetch.result

# promise:
# - [state/expected_sha256] consistent with {$(sha256), $(tarball_path)};
#   only updated when contents changed
#   (so [state/expected.sha256] works well as make dependency)
#
# (reminder: state/fetch.result here needed so that 'make all' in initial state does fetch,
#  since require-sha256 checks that tarball path is present + additionally produces actual sha256)
#
sha256 state/expected.sha256: state/fetch.result
	$(TOP_DIR)/mk/require-sha256.sh --sha256=$(sha256) --tarball-path=$(tarball_path)

state/verify.result: state/expected.sha256 
	$(TOP_DIR)/mk/verify-sha256.sh

verify: state/verify.result

unpack: verify
	@echo placeholder: unpack

patch: unpack
	@echo placeholder: patch

config: patch
	@echo placeholder: config

compile: config
	@echo placeholder: compile

install:
	@echo placeholder: install

verifyclean:
	rm -f state/verify.result

# unwind to state before src.
# preserves:
# - tarball in $(tarball_path)
# - cksum state
#
unpackclean:
	@echo "placeholder: unpackclean"

clean:
	@echo "placeholder: clean"

# unwind to state before fetch.
distclean: 
	rm -f $(tarball_path)
	rm -f state/*
	rm -f log/*

