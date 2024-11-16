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

# NOTE: for mdbook, trying a binary release.
#       Building from source would require we add to nix-from-scratch:
#          - rust
#          - cargo
#          - llvm
#       which we'd like to avoid diving into for now

version:=0.4.40
# unique package name
#name:=mdBook-$(version)
name:=mdbook-v$(version)
# local directory for unpacked source
unpackdir:=mdbook
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
#url:=https://github.com/rust-lang/mdBook/archive/refs/tags/v$(version).tar.gz
url:=https://github.com/rust-lang/mdBook/releases/download/v$(version)/mdbook-v$(version)-x86_64-unknown-linux-gnu.tar.gz
# verify this sha
#sha256:=550da7ff02ef62c60db6e813b6dbae65b9ed3d491186ea74929536feaceea94b
sha256:=9ef07fd288ba58ff3b99d1c94e6d414d431c9a61fdb20348e5beb74b823d546b

#
cflags:=-I$(PREFIX)/include
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
patch_script:=
srcdir:=binary
builddir:=build
pre_configure_hook:=
# noop configure
configure_exec:=true
configure_extra_args:=
build_exec:=true
install_exec:=cp
install_args:=../binary $(PREFIX)/bin/mdbook
post_install_hook:=

all: compile

include $(TOP_DIR)/mk/buildphases.mk
