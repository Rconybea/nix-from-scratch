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

version:=6.5
stem:=ncurses
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://invisible-mirror.net/archives/$(stem)/$(tarball)
# verify this sha
sha256:=136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6
# Settings cflags seems to cause a problem with libuv
# (compile errors involving attempts to use a non-existent 'heap_node' member in a uv timer)
# Without them cmake looks like it builds with its own libuv
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
# in-tree build, 
builddir:=build
pre_configure_hook:=
configure_exec:=
configure_extra_args:=--mandir=$(PREFIX)/share/man --with-shared --without-normal --without-debug --with-cxx-shared --enable-pc-files --with-pkgs-config-libdir=$(PREFIX)/lib/pkgconfig 
build_exec:=
build_args:=
install_exec:=../ncurses-install.sh
install_args:=--prefix=$(PREFIX)
post_install_hook:=

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

