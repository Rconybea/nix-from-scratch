# default below replaced by ./bootstrap.sh --prefix=PREFIX
PREFIX:=$(HOME)/ext

NIX_PREFIX:=$(shell realpath $(HOME)/nixroot)
# NOTE: /nix/store in standard nix install
NIX_STORE_DIR:=$(NIX_PREFIX)/nix/store
# NOTE: /usr/share/doc/nix in standard nix install
NIX_DOC_DIR:=$(NIX_PREFIX)/doc
# NOTE: /nix/var in standard nix install 
NIX_LOCALSTATE_DIR:=$(NIX_PREFIX)/var
# NOTE: /etc/nix in standard nix install 
NIX_SYSCONF_DIR:=$(NIX_PREFIX)/etc
# NOTE: /usr

# install crostool-ng under this prefix
#
NXFS_TOOLCHAIN_PREFIX:=$(HOME)/nxfs-toolchain

# create subdirs under this prefix
# for packages that we will adopt into nix store to bootstrap stdenv.
# 
NXFS_BOOTSTRAP_PREFIX:=$(NIX_PREFIX)/bootstrap

# use --host=$(NXFS_HOST_TUPLE) --build=$(NXFS_BUILD_TUPLE)
# when configuring a package for nix bootstrap
#
NXFS_HOST_TUPLE:=x86_64-pc-linux-gnu
NXFS_BUILD_TUPLE:=x86_64-pc-linux-gnu

NXFS_TOOLCHAIN_SYSROOT:=$(NXFS_TOOLCHAIN_PREFIX)/$(NXFS_HOST_TUPLE)/sysroot
