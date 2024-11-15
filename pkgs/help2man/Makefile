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

version:=1.49.3
stem:=help2man
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://mirrors.ibiblio.org/gnu/$(stem)/$(tarball)
# verify this sha
sha256:=4d7e4fdef2eca6afe07a2682151cea78781e0a4e8f9622142d9f70c083a2fd4f
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
configure_extra_args:=
build_exec:=
build_args:=
install_exec:=
install_args:=
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

