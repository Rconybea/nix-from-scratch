# Top-level makefile for nix-from-scratch build
#
# Orchestrates nix-dependency build across set of nix dependencies
#
#   $ make all    build all nix dependencies
#

# Packages to build.  A target p_foo delegates to foo/Makefile
# 
ALL_PACKAGES:=$(wildcard pkgs/*)

.PHONY: all
all: $(ALL_PACKAGES)

.PHONY: $(ALL_PACKAGES)
$(ALL_PACKAGES):
	$(MAKE) -C $@ $(MAKECMDGOALS)

PHASE:=fetch src patch config compile install clean srcclean distclean
.PHONY: $(PHASE)
$(PHASE):
	for dir in $(ALL_PACKAGES); do $(MAKE) -C $$dir $@; done
