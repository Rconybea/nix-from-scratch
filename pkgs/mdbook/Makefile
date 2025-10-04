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

# now just using cargo, see mdbook-install.sh

# local directory for unpacked source
unpackdir:=mdbook
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
patch_script:=
srcdir:=
builddir:=build
pre_configure_hook:=
# noop configure
configure_exec:=true
configure_extra_args:=
# noop build
build_exec:=true
# install fetches+builds via cargo
install_exec:=$(THIS_DIR)/mdbook-install.sh
install_args:=--prefix=$(PREFIX)
post_install_hook:=

all: compile

# fetch tarball
#
# on success:
# - state/fetch.result holds tarball_path
# on failure:
# - state/fetch.result holds error message
#
$(tarball_path) state/fetch.result: 
	$(TOP_DIR)/scripts/init.sh --archive-dir=$(ARCHIVE_DIR)
	echo "noop fetch"

# - noop when $(tarball_path) already established
#   (use `make distclean` to do-over)
#
.PHONY: fetch
fetch: state/fetch.result

sha256 state/expected.sha256: state/fetch.result
	echo "noop sha256" > state/expected.sha256

state/verify.result: 
	echo "noop verify" > state/verify.result

# - noop when state/verify.result already established
#   (use `make verifyclean` to do-over)
#
.PHONY: verify
verify: state/verify.result

state/unpack.result: state/verify.result 
	echo "noop unpack" > state/unpack.result

.PHONY: unpack
unpack: state/unpack.result

# provides targets:
# - state/patch.result
# - patch
#
include $(TOP_DIR)/mk/patch.mk

# provides targets:
# - state/config.result
# - config
#
include $(TOP_DIR)/mk/configure.mk

# provides targets:
# - state/compile.mk
# - compile
#
include $(TOP_DIR)/mk/compile.mk

# provides targets:
# - state/install.mk
# - install
#
include $(TOP_DIR)/mk/install.mk

# provides targets:
# - distclean
# - verifyclean
# - unpackclean
# - configclean
# - clean
#
include $(TOP_DIR)/mk/clean.mk
