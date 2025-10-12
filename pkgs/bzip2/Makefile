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

version:=1.0.8
stem:=bzip2
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://www.sourceware.org/pub/$(stem)/$(tarball)
# verify this sha
sha256:=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
#
cflags:=
#cflags:=-I$(PREFIX)/include
ldflags:=
#ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
srcdir:=src
patch_script:=patch-bzip2.sh
#
pre_configure_hook:=
# custom 'configure' step
configure_exec:=true
# invoked from $(builddir)
configure_script:=
configure_extra_args:=
# in-source-tree build only
builddir:=src
build_exec:=../bzip2-build.sh
build_args:=
#
install_exec:=make
install_args:=PREFIX=$(PREFIX) install
#
post_install_hook:=./bzip2-postinstall.sh --prefix=$(PREFIX) --build-dir=$(builddir)

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

