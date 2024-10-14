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

version:=2.6.2
# unique package name
name:=expat-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://prdownloads.sourceforge.net/expat/$(tarball)
# verify this sha
sha256:=ee14b4c5d8908b1bec37ad937607eab183d4d9806a08adee472c3c3121d27364
# Settings CFLAGS seems to break the flex configure script;
# complains that it can't invoke gcc.
cflags:=-I$(PREFIX)/include
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
configure_extra_args:=--docdir=$(PREFIX)/share/doc/$(name)
post_install_hook:=./post-install-hook.sh --name=$(name) --prefix=$(PREFIX) --srcdir=$(srcdir)

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
