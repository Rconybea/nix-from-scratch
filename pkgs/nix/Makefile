# Always gets directory containing this Makefile, regardless of cwd
THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# Always root directory for nix-from-scratch (even if not a git repo)
TOP_DIR:=$(realpath $(THIS_DIR)/../..)

# NOTE: / in standard nix install
NIX_PREFIX:=$(HOME)/nixroot
export NIX_PREFIX

# NOTE: /nix/store in standard nix install
NIX_STORE_DIR:=$(NIX_PREFIX)/nix/store
# NOTE: /nix/var in standard nix install 
NIX_LOCALSTATE_DIR:=$(NIX_PREFIX)/var
# NOTE: /etc/nix in standard nix install 
NIX_SYSCONF_DIR:=$(NIX_PREFIX)/etc


# provides:
#   TOP_DIR
#   ARCHIVE_DIR
#   PREFIX           exported
#   PATH             exported
#   PKG_CONFIG_PATH  exported
#
include $(TOP_DIR)/mk/config.mk

version:=2.24.9
# unique package name
name:=nix-$(version)
# local directory for unpacked source
srcdir:=$(name)
# unique tarball name (in ARCHIVE_DIR)
tarball:=$(name).tar.gz
# full path to local tarball
tarball_path:=$(ARCHIVE_DIR)/$(tarball)
# obtain tarball by fetching from this url
#url:=https://ftp.gnu.org/gnu/automake/$(tarball)
url:=https://github.com/NixOS/nix/archive/refs/tags/$(version).tar.gz
# verify this sha
sha256:=0114c923daef3d0baeaf1f7b5a7618c38c34853f0a10a1931fa12d9a1f390726
cppflags:=-I$(PREFIX)/include -Wno-suggest-override
ldflags:=-L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib
#
# note: patch script invoked in $(srcdir)
patch_script:=./patch.sh
# need in-source build for nix
builddir:=build
# disabling --enable-lto bc preparing this on wsl:
# 1. gcc 11.4 missing a specific bug fix
# 2. setting CXX=g++-12 causes configure to think compiler is *not* gcc!
# 3. cannot rely on LD_RUN_PATH, since gets overwritten/ignored by nix build
# 4. doc generation requires mdBook, which in turn requires rust (which has big dependencies like llvm)
#    Omitting this for expedience, since seems like a pretty big dependency to pick up for
#    something we can live without
# Also:
# 5. suppress gcc error from boost 1.86.0, get warning because basic_altstringbuf methods no marked as override,
#    and this gets escalated to an error
# 6. nix builds with switch-enum treated as error,  but (at least on gcc 11.4)
#    this warning triggers even on switch statements with a default branch (?!),
#    and such appear in toml11-4.2.0 headers.
#
#    In nix-$(version)/local.mk:
#       ERROR_SWITCH_ENUM = -Werror=switch-enum
#    we suppress this with patch
#  
# pre_configure_hook + configure script: runs in build dir
pre_configure_hook:=../pre-configure-hook.sh --srcdir=$(srcdir) 
configure_script:=configure
configure_extra_args:=--with-store-dir=$(NIX_STORE_DIR) --prefix=$(NIX_PREFIX) --sysconfdir=$(NIX_SYSCONF_DIR) --localstatedir=$(NIX_LOCALSTATE_DIR) --enable-gc --disable-doc-gen CXX=g++-12 LIBSECCOMP_FLAGS=-I$(PREFIX)/include
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

# note: passing --build-dir=$(srcdir) here
state/config.result $(builddir): state/patch.result
	@#mkdir -p $(builddir)
	$(TOP_DIR)/mk/configure-autotools.sh \
       --pre-configure-hook="$(pre_configure_hook)" \
       --configure-exec=$(configure_exec) \
	   --configure-script=$(configure_script) \
       --prefix=$(PREFIX) --src-dir=$(srcdir) --build-dir=$(srcdir) \
       --cflags="$(cflags)" --cppflags="$(cppflags)" --ldflags="$(ldflags)" \
       --configure-extra-args="$(configure_extra_args)"


.PHONY: config
config: state/config.result

# provides targets:
# - state/compile.mk
# - compile
#
state/compile.result: state/config.result
	(cd $(srcdir) && make profiledir=$(NIX_SYSCONF_DIR)/profile.d V=1 CPPFLAGS="$(cppflags)" LDFLAGS="$(ldflags)")
	cp state/patch.result state/compile.result

.PHONY: compile
compile: state/compile.result $(srcdir)

# nix install step invokes compiler again,  so we need LDFLAGS
#
state/install.result:
	mkdir -p $(NIX_STORE_DIR) $(NIX_SYSCONF_DIR) $(NIX_LOCALSTATE_DIR)/nix
	(cd $(srcdir) && make install sysconfdir=$(NIX_SYSCONF_DIR) V=1 LDFLAGS="$(ldflags)")
	echo ok > $@

.PHONY: install
install: state/install.result

# provides targets:
# - distclean
# - verifyclean
# - unpackclean
# - configclean
# - clean
#
include $(TOP_DIR)/mk/clean.mk

