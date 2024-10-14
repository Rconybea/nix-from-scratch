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

version:=2.6.4
# unique package name
name:=flex-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://github.com/westes/flex/releases/download/v$(version)/$(tarball)
# verify this sha
sha256:=e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995
# Settings CFLAGS seems to break the flex configure script;
# complains that it can't invoke gcc.
cflags:=-I$(PREFIX)/include
#cflags:=
# 1. the configure script in flex seems to get confused by LDFLAGS="..." with rhs containing a space
#    (other configure scripts are ok with this)
# 2. fortunately flex doesn't need other libraries from $(PREFIX)/lib
# 3. if this changes, may want to try invoking compile step with LD_RUN_PATH=$(PREFIX)/lib
#    as alternative
ldflags:=-Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
builddir:=build
configure_extra_args:=--docdir=$(PREFIX)/share/doc/$(name) --enable-static --enable-shared
post_install_hook:=./post-install-hook.sh --prefix=$(PREFIX)

COMMANDS:=all sha256 clean unpackclean distclean
.PHONY: $(COMMANDS)

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
