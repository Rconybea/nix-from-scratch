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
sha256:=a695629dae047055b37d50a0ff4776d1d45d0a4c842cf4ccee158441f55ff7ee
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

include $(TOP_DIR)/mk/buildphases.mk
