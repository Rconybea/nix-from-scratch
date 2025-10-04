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

stem:=rustc
#version:=1.80.1 # not sufficient for mdbook
version:=1.89.0
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)-src
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name)-src.tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://static.rust-lang.org/dist/$(tarball)
# verify this sha
sha256:=0b9d55610d8270e06c44f459d1e2b7918a5e673809c592abed9b9c600e33d95a
#cflags:=-I$(PREFIX)/include
cflags:=
#ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
ldflags:=
#
patch_script:=
srcdir:=src
builddir:=build
pre_configure_hook:=
configure_script:=../rustc-configure.sh
configure_extra_args:=--prefix=$(PREFIX) --sysconfdir=$(PREFIX)/etc --docdir=share/doc/$(name)
build_exec:=../rustc-compile.sh
build_args:=../src/x.py build
install_exec:=../rustc-install.sh
install_args:=--prefix=$(PREFIX) --docdir=$(PREFIX)/share
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
