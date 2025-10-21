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
EXT_PREFIX:=$(PREFIX)
PREFIX:=$(shell realpath ../$(stem))

# Get unique nix location where nxfs-sysroot-0 installed
#
# REQUIRE:
#  - sysroot available in nix store
#
sysroot_storepath:=$(shell nix-build ../../nxfs-toolchain-0)
libxcrypt_storepath:=$(shell nix-build ../../nxfs-libxcrypt-0)

version_major=5.0
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
url:=https://www.cpan.org/src/$(version_major)/$(tarball)
# verify this sha
sha256:=d5325300ad267624cb0b7d512cfdfcd74fa7fe00c455c5b51a6bd53e5e199ef9
#
cflags:=-I$(EXT_PREFIX)/include -I$(sysroot_storepath)/include
ldflags:=-L$(libxcrypt_storepath)/lib -Wl,-enable-new-dtags -Wl,-rpath,$(libxcrypt_storepath)/lib -Wl,-rpath,$(sysroot_storepath)/lib -L$(EXT_PREFIX)/lib -Wl,-rpath,${EXT_PREFIX}/lib -Wl,-dynamic-linker,$(sysroot_storepath)/lib/ld-linux-x86-64.so.2
#
patch_script:=
srcdir:=src
builddir:=src
pre_configure_hook:=
configure_exec:=sh
# see ./configure_perl.sh.  Needs cript because cflags contains embedded space.
#configure_extra_args:=Configure -des -Dprefix=$(PREFIX) -Dccflags=$(cflags) -Dvendorprefix=$(PREFIX) -Duseshrplib -Dprivlib=$(PREFIX)/lib/perl5/$(version_major_minor)/core_perl -Darchlib=$(PREFIX)/lib/perl5/$(version_major_minor)/core_perl -Dsitelib=$(PREFIX)/lib/perl5/$(version_major_minor)/site_perl -Dsitearch=$(PREFIX)/lib/perl5/$(version_major_minor)/site_perl -Dvendorlib=$(PREFIX)/lib/perl5/$(version_major_minor)/vendor_perl -Dvendorarch=$(PREFIX)/lib/perl5/$(version_major_minor)/vendor_perl

post_install_hook:=./perl-post-install-hook.sh --prefix=$(PREFIX) --runpath=$(libxcrypt_storepath)/lib:$(sysroot_storepath)/lib --version-major-minor=$(version_major_minor)

.PHONY: all
all: install

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

state/config.result $(builddir): state/patch.result
	mkdir -p $(builddir)
	(./configure_perl.sh --local-prefix=$(EXT_PREFIX) --prefix=$(PREFIX) --src-dir=$(srcdir) --cflags="$(cflags)" --ldflags="$(ldflags)" --version-major-minor=$(version_major_minor) 2>&1) | tee log/config.log

.PHONY: config
config: state/config.result

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


