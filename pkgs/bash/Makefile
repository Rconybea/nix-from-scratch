# Always gets directory containing this Makefile, regardless of cwd
THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# Always root directory for nix-from-scratch (even if not a git repo)
TOP_DIR:=$(realpath $(THIS_DIR)/../..)
export TOP_DIR

# provides:
#   TOP_DIR
#   ARCHIVE_DIR
#   PREFIX           exported
#   PATH             exported
#   PKG_CONFIG_PATH  exported
#
include $(TOP_DIR)/mk/config.mk

version:=5.2.32
# unique package name
name:=bash-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
url:=https://ftp.gnu.org/gnu/bash/bash-5.2.32.tar.gz
# verify this sha
sha256:=d3ef80d2b67d8cbbe4d3265c63a72c46f9b278ead6e0e06d61801b58f23f50b5
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=src
builddir:=build
pre_configure_hook:=
configure_extra_args:=--without-bash-malloc bash_cv_strtold_broken=no
post_install_hook:=$(THIS_DIR)/post-install-hook.sh --name=$(name) --prefix=$(PREFIX)

all: compile

include $(TOP_DIR)/mk/buildphases.mk

