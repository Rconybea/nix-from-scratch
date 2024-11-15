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

version:=1.5.0
# unique package name
name:=zstd-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/m4/$(tarball)
url:=https://github.com/facebook/zstd/releases/download/v$(version)/$(tarball)
# verify this sha
sha256:=5194fbfa781fcf45b98c5e849651aa7b3b0a008c6b72d4a0db760f3002291e94
#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
# in-source-tree build
builddir:=src
configure_exec:=true
configure_extra_args:=
build_args:=MOREFLAGS=$(cflags)
install_args:=prefix=$(PREFIX) install
post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk
