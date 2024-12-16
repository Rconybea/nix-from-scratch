# Always gets directory containing this Makefile, regardless of cwd
THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# Always root directory for nix-from-scratch (even if not a git repo)
TOP_DIR:=$(realpath $(THIS_DIR)/../../../..)

# provides:
#   TOP_DIR
#   ARCHIVE_DIR
#   PREFIX           exported
#   PATH             exported
#   PKG_CONFIG_PATH  exported
#
include $(TOP_DIR)/mk/config.mk

stem:=perl
PREFIX:=$(shell realpath ../$(stem))

# Get unique nix location where nxfs-sysroot-0 installed
#
# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-sysroot-0)

version_major_minor=5.40
version:=5.40.0
# unique package name
name:=$(stem)-$(version)
# local directory for unpacked source
unpackdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.xz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
url:=https://www.cpan.org/src/5.0/$(tarball)
# verify this sha
sha256:=d5325300ad267624cb0b7d512cfdfcd74fa7fe00c455c5b51a6bd53e5e199ef9
#
cflags:=-I$(sysroot_storepath)/usr/include
ldflags:=-Wl,-enable-new-dtags -Wl,-rpath,$(sysroot_storepath)/usr/lib -Wl,-rpath,$(sysroot_storepath)/lib -Wl,-dynamic-linker,$(sysroot_storepath)/lib/ld-linux-x86-64.so.2
#
patch_script:=
srcdir:=src
builddir:=src
pre_configure_hook:=
configure_exec:=sh
configure_extra_args:=Configure -des -Dprefix=$(PREFIX) -Dccflags=$(cflags) -Dvendorprefix=$(PREFIX) -Duseshrplib -Dprivlib=$(PREFIX)/lib/perl5/$(version_major_minor)/core_perl -Darchlib=$(PREFIX)/lib/perl5/$(version_major_minor)/core_perl -Dsitelib=$(PREFIX)/lib/perl5/$(version_major_minor)/site_perl -Dsitearch=$(PREFIX)/lib/perl5/$(version_major_minor)/site_perl -Dvendorlib=$(PREFIX)/lib/perl5/$(version_major_minor)/vendor_perl -Dvendorarch=$(PREFIX)/lib/perl5/$(version_major_minor)/vendor_perl
post_install_hook:=

.PHONY: all
all: install

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
