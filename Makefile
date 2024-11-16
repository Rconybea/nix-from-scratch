# Top-level makefile for nix-from-scratch build
#
# Orchestrates nix-dependency build across set of nix dependencies
#
#   $ make all    build all nix dependencies
#

TOP_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

include $(TOP_DIR)/mk/config.mk

# Packages to build.  A target p_foo delegates to foo/Makefile
# 
ALL_PACKAGES:=$(wildcard pkgs/*)

.PHONY: all
all: pkgs/nix

.PHONY: init
init:
	mkdir -p $(ARCHIVE_DIR)

.PHONY: $(ALL_PACKAGES)
$(ALL_PACKAGES): init
	$(MAKE) -C $@ install

PHASE:=fetch unpack patch config compile install clean srcclean unpackclean configclean distclean installclean
.PHONY: $(PHASE)
$(PHASE):
	for dir in $(ALL_PACKAGES); do $(MAKE) -C $$dir $@ || echo "$$dir failed"; done

# ----------------------------------------------------------------
# inter-package dependencies
# ----------------------------------------------------------------

.PHONY: nix-deps
nix-deps: pkgs/nlohmann_json pkgs/libtool pkgs/automake pkgs/autoconf-archive pkgs/jq pkgs/editline pkgs/libsodium pkgs/brotli pkgs/libcpuid pkgs/libseccomp pkgs/boehm-gc pkgs/gtest pkgs/rapidcheck pkgs/libgit2 pkgs/toml11 pkgs/lowdown pkgs/bison pkgs/mdbook-linkcheck pkgs/mdbook

.PHONY: pkgs/nix
pkgs/nix: nix-deps

.PHONY: pkgs/mdbook
pkgs/mdbook: 

.PHONY: pkgs/mdbook-linkcheck
pkgs/mdbook-linkcheck:

.PHONY: pkgs/unzip
pkgs/unzip: pkgs/autoconf

.PHONY: pkgs/lowdown
pkgs/lowdown: pkgs/autoconf

.PHONY: pkgs/bison
pkgs/bison: pkgs/flex

.PHONY: pkgs/flex
pkgs/flex: pkgs/autoconf

.PHONY: pkgs/toml11
pkgs/toml11: pkgs/cmake 

.PHONY: pkgs/ncurses
pkgs/ncurses: pkgs/pkgconf

.PHONY: pkgs/readline
pkgs/readline: pkgs/ncurses

.PHONY: pkgs/pcre
pkgs/pcre: pkgs/readline pkgs/bzip2 pkgs/zlib

.PHONY: pkgs/libgit2
pkgs/libgit2: pkgs/cmake pkgs/python pkgs/libssh2 pkgs/pcre

.PHONY: pkgs/rapidcheck
pkgs/rapidcheck: pkgs/gtest pkgs/boost

.PHONY: pkgs/gtest
pkgs/gtest: pkgs/cmake pkgs/python

.PHONY: pkgs/boehm-gc
pkgs/boehm-gc: pkgs/autoconf

.PHONY: pkgs/libseccomp
pkgs/libseccomp: pkgs/gperf

.PHONY: pkgs/gperf
pkgs/gperf: pkgs/autoconf

.PHONY: pkgs/libsodium
pkgs/libsodium: pkgs/autoconf

.PHONY: pkgs/editline
pkgs/editline: pkgs/autoconf

.PHONY: pkgs/boost
pkgs/boost: pkgs/python

.PHONY: pkgs/python
pkgs/python: pkgs/sqlite pkgs/expat pkgs/zlib

.PHONY: pkgs/jq
pkgs/jq: pkgs/autoconf

.PHONY: pkgs/nlohmann_json
pkgs/nlohmann_json: pkgs/cmake

.PHONY: pkgs/curl-stage2
pkgs/curl-stage2: pkgs/brotli pkgs/cmake pkgs/curl-stage1

.PHONY: pkgs/brotli
pkgs/brotli: pkgs/cmake pkgs/curl-stage1 pkgs/patchelf

.PHONY: pkgs/patchelf
pkgs/patchelf: pkgs/autoconf

.PHONY: pkgs/cmake
pkgs/cmake: pkgs/curl-stage1 pkgs/libarchive pkgs/libuv

.PHONY: pkgs/libuv
pkgs/libuv: pkgs/automake pkgs/libtool

.PHONY: pkgs/libarchive
pkgs/libarchive: pkgs/bzip2 pkgs/expat pkgs/autoconf

.PHONY: pkgs/expat
pkgs/expat: pkgs/autoconf

.PHONY: pkgs/curl-stage1
pkgs/curl-stage1: pkgs/pkgconf pkgs/openssl pkgs/zstd

.PHONY: pkgs/zstd
pkgs/zstd: pkgs/zlib

.PHONY: pkgs/libssh2
pkgs/libssh2: pkgs/openssl

.PHONY: pkgs/openssl
pkgs/openssl: pkgs/perl pkgs/zlib

.PHONY: pkgs/perl
pkgs/perl: 

.PHONY: pkgs/sqlite
pkgs/sqlite: pkgs/pkgconf pkgs/libtool

.PHONY: pkgs/pkgconf
pkgs/pkgconf: pkgs/autoconf

.PHONY: pkgs/zlib
pkgs/zlib:  pkgs/autoconf

.PHONY: pkgs/libcpuid
pkgs/libcpuid: pkgs/automake pkgs/libtool

.PHONY: pkgs/libtool
pkgs/libtool: pkgs/m4

.PHONY: pkgs/automake
pkgs/automake: pkgs/autoconf

.PHONY: pkgs/autoconf-archive
pkgs/autoconf-archive: pkgs/autoconf

.PHONY: pkgs/autoconf
pkgs/autoconf: pkgs/m4

.PHONY: pkgs/m4
pkg/m4:

.PHONY: pkgs/texinfo
pkgs/texinfo: pkgs/autoconf

# ----------------------------------------------------------------
# additional deps for crosstool-ng 

.PHONY: pkgs/bzip2
pkgs/bzip2:

# ----------------------------------------------------------------

.PHONY: pkgs/gcc
pkgs/gcc: pkgs/mpc pkgs/gmp pkgs/mpfr

# really glibc stage1
.PHONY: pkgs/glibc
pkgs/glibc: pkgs/bison

.PHONY: pkgs/mpc
pkgs/mpc:

.PHONY: pkgs/gmp
pkgs/gmp:

.PHONY: pkgs/mpfr
pkgs/mpfr:

.PHONY: pkgs/stage1-binutils
pkgs/stage1-binutils: pkgs/texinfo 

