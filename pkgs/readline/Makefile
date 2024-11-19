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

version:=8.1
stem:=readline
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://ftp.gnu.org/gnu/$(stem)/$(tarball)
# verify this sha
sha256:=f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
srcdir:=src
patch_script:=readline-patch.sh
configure_extra_args:=--with-curses --docdir=$(PREFIX)/share/doc/$(name)
builddir:=build
install_args:=SHLIB_LIBS=-lncursesw install
# install docs w/
#  install -v -m644 doc/*.ps $(PREFIX)/share/doc/$(name)
#  install -v -m644 doc/*.pdf $(PREFIX)/share/doc/$(name)
#  install -v -m644 doc/*.html $(PREFIX)/share/doc/$(name)
#  install -v -m644 doc/*.dvi $(PREFIX)/share/doc/$(name)
#
.PHONY: all
all: compile

# provides targets:
# - $(tarball_path)
# - state/fetch.result
# - fetch
# - sh256
# - state/expected.sha256
# - state/verify.result
# - verify
# - state/unpack.result
# - unpack
# - state/patch.result
# - patch
# - state/config.result
# - config
# - state/compile.mk
# - compile
# - state/install.mk
# - install
# - distclean
# - verifyclean
# - unpackclean
# - configclean
# - clean
#
include $(TOP_DIR)/mk/buildphases.mk

