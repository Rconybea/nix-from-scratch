#!/bin/bash

echo "This is a fixed-output derivation for the nix-from-scratch project."
echo "Intended use is to bootstrap from an empty nix store."
echo "Derivation output is prepared outside nix and uploaded directly."
echo ""
echo "Nix should not normally try to build this derivation."
echo ""
echo "See:"
echo " - https://github.com/rconybea/nix-from-scratch"
echo "   project responsible for this script"
echo ""
echo " - nix-from-scratch/pkgs/crosstool-ng"
echo "   builder for toolchain (including sysroot subdir belonging with this derivation)"
echo ""
echo " - nix-from-scratch/crosstool/.config"
echo "   config for toolchain (constructed using crosstool-ng)"
echo ""
echo " - nix-from-scratch/bootstrap/nxfs-sysroot-0/copy2nix.sh"
echo "   script to upload prepared subtree to nix store + create default.nix"
echo ""

exit 0
