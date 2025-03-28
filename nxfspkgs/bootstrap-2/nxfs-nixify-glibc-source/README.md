Helper to massage glibc source before building.

This consists of
1. unpacking tarball to get source tree,
2. copying source tree to derivation output
3. rewriting unreachable paths like /bin/bash (so that they work from inside nix-build)

Putting this in a separate derivation for two reasons.
1. to save time -- the expansion + rewrite takes about a minute on author's primary dev machine.
2. share rewrite rules across bootstrap stages that build gcc.
