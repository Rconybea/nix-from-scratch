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
name:=zlib-1.3.1
# local directory for unpacked source
srcdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/m4/$(tarball)
url:=https://zlib.net/fossils/$(tarball)
# verify this sha
sha256:=9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23
# zlib ./configure does not accept CFLAGS or LDFLAGS
cflags:=
ldflags:=
#
patch_script:=
builddir:=build
configure_extra_args:=
post_install_hook:=

all: compile

# provides targets:
# - $(tarball_path)
# - state/fetch.result
# - fetch
#
include $(TOP_DIR)/mk/fetch.mk

# provides targets:
# - sh256
# - state/expected.sha256
# - state/verify.result
# - verify
#
include $(TOP_DIR)/mk/verify.mk

# provides targets:
# - state/unpack.result
# - unpack
#
include $(TOP_DIR)/mk/unpack.mk

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
