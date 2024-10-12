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

version:=4.2.0
# unique package name
name:=toml11
# local directory for unpacked source
srcdir:=$(name)-$(version)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
url:=https://github.com/ToruNiina/toml11/archive/refs/tags/v$(version).tar.gz
# verify this sha
sha256:=9287971cd4a1a3992ef37e7b95a3972d1ae56410e7f8e3f300727ab1d6c79c2c
#
# {cflags,ldflags} won't work when configure_script=cmake
#cflags:=-I$(PREFIX)/include
#ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
builddir:=build
pre_configure_hook:=
configure_exec:=cmake
configure_script:=
# note: toml11 is header-only
configure_extra_args:=-DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_INSTALL_RPATH=$(PREFIX)/lib -DCMAKE_CXX_FLAGS=-I$(PREFIX)/include -B . -S ../$(srcdir)
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

