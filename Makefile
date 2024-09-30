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
all: $(ALL_PACKAGES)

.PHONY: init
init:
	mkdir -p $(ARCHIVE_DIR)

.PHONY: $(ALL_PACKAGES)
$(ALL_PACKAGES): init
	$(MAKE) -C $@ $(MAKECMDGOALS)

PHASE:=fetch src patch config compile install clean srcclean distclean
.PHONY: $(PHASE)
$(PHASE):
	for dir in $(ALL_PACKAGES); do $(MAKE) -C $$dir $@; done

# ----------------------------------------------------------------
# inter-package dependencies
# ----------------------------------------------------------------

pkgs/autoconf: pkgs/m4
pkgs/autoconf-archive: pkgs/autoconf
