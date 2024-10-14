![Build Status on github actions](https://github.com/Rconybea/nix-from-scratch/actions/workflows/main.yml/badge.svg)
![Build Status on github actions](https://github.com/Rconybea/nix-from-scratch/actions/workflows/dev.yml/badge.svg)
[![Version](https://img.shields.io/badge/release-v0.37.0-blue)](https://github.com/Rconybea/nix-from-scratch/releases)
[![License](https://img.shields.io/github/license/ToruNiina/toml11.svg?style=flat)](LICENSE)

# nix-from-scratch

Build nix packager and dependencies:
1. from source code
2. with dependencies
3. without requiring write access to LSB directories

## Why nix-from-scratch?

The purpose of this project is to provide a last-resort build
for the nix package manager.  Intended to make it easier to use
nix when standard installation paths are not feasible.

## When do I need this?

When other (simpler, preferred) ways to install nix are not possible,
or impose costs that are too high.

For example, when writing software in a corporate linux environment,
not unusual for all the following to apply:

1. Operating system support and software development responsibilities are divided
between different departments;  with natural result that developers work
with reduced system privileges:

2. Readonly system directories `/usr`, `/etc`, `/bin` etc.

3. Operating system chosen with stability as a primary goal.
Often an older linux release, with correspondingly out-of-date toolchain.

4. Package selection limited for the same reason.
Unprivileged users may not have permission to install packages.

5. Secure network. Connecting a personal computer to corporate
network is (with good reason) prevented and forbidden.

6. Same restrictions likely apply to production software created by
the engineering organization -- organization may have already decided
where in filesystem to put artifacts produced by the engineering organization,
with institutional barriers to changing that.

Together, these restrictions prevent many typical installation pathways for nix.

To decide if `nix-from-scratch` might help you, answer these questions:

### Q1: Can you write to `/` ?

Nix needs a well-known place to store build artifacts;
usually this is under the directory `/nix/store`.  If you can arrange to have write
access to this directory, then easiest way to install nix is to use the standard
install here https://nixos.org/download/

For example, start a standard single-user binary installation with
```
$ sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

If you can create and/or write to `/nix`, then you should expect to be able
to (and prefer to) use a binary nix install as above.

### Q2: Does your OS kernel support user namespaces?

Even if *you* can't wite to `/nix`,  you may be able to create a user namespace
in which `/nix` appears to exist,  but 'really' maps to some other directory.

One way to see if this is the case:

```
$ unshare --user --pid echo YES
YES
```

If this runs without error, then user namespaces are available.

In that case easiest way to install nix is to setup a user chroot in which `/nix` points
to some user-writeable directory, say `$HOME/nix`.

You can get a nix-centric user chroot program here: https://github.com/nix-community/nix-user-chroot
Alternatively, this C version might work for you: https://github.com/lucabrunox/nix-user-chroot

If user namespaces are enabled, you also would like to know whether they can be nested.

Some nix features,  for example I believe

```
$ nix run --store ~/my-nix nixpkgs.nix nixpkgs.bashInteractive
```

work by starting a user namespace; if you're using user namespace to get access to nix,
then running code like the above requires nestable namespaces.

### Q3: Can you invoke operating systems' package manager to install recent package versions?

For example, if operating system is a debian derivative, can you do something like:
```
$ apt-get install gcc-12
```

If so, may prefer to install nix dependencies from package manager instead of building them
yourself.  Will have to at least build `nix` from source, unless (unlikely afaik) package repository
has a prebuilt package for `nix` available.

### Q4: Do you want to release libraries/artifacts built with nix, without using namespaces?

If you use a user namespace to provide `/nix/store`,  the resulting artifacts will only run
on a host where `/nix/store` exists,  or where you use a user-namespace to
provide that appearance. If either of these is viable,  then you can use a binary nix
distribution and rely on the standard easy install.

If answers to Q1..Q4 are all unsatisfactory, read on...

## nix-from-scratch

In this project, we're going to workaround the restrictions above "the hard way".
In the spirit of the linuxfromscratch project (https://www.linuxfromscratch.org ) we will proceed
as follows:

1. Fetch and build each nix dependency from an authoritative source tarball.

2. Install to a common but non-LSB location (`$HOME/ext`). If we can't create/read/write `/nix`,
probably can't touch `/usr` or `/usr/local` either.

In particular, we assume that we're installing to a directory that `ldconfig` doesn't know about.
this means that in general, if (a) we have two libraries {L, M} installed `/path/to/foo`
(i.e. `$HOME/ext/lib`), and (b) L depends on M:
then we want L to have a `RUNPATH` entry `/path/to/foo` so that loader can find M when it encounters L.

3. Since there will be several dozen dependencies, we will prepare a modest meta-build system to
build them.  Though much less capable than nix, this will still give us a permanent record of how to
bootstrap core depenencies.

4. Once all its dependencies are installed,  we'll proceed to build `nix` itself.

### nix install locations

We will use the following paths:

1. `PREFIX=$HOME/ext/{bin,lib,etc,share}` (instead of `/usr`).  This is where we install nix dependencies,
including `nix` binaries and libraries themselves

2. `NIX_PREFIX=$HOME/nixroot` (instead of `/`).

3. store directory `$HOME/nixroot/nix/store` (instead of `/nix/store`)

4. configuration directory `$HOME/nixroot/var` (instead of `/var`)

5. system configuration directory `$HOME/nixroot/etc` (instead of `/etc`).

### Meta-build Instructions

1. Download release

  ```
  curl -L https://github.com/Rconybea/nix-from-scratch/archive/refs/tags/nix-from-scratch-0.37.0.tar.gz
  tar xf nix-from-scratch-0.37.0.tar.gz
  srcdir=nix-from-scratch-0.37.0
  ```

2. Choose dependency install location

Edit `nix-from-scratch-${version}/mk/prefix.mk`, choose value for `PREFIX`.
This will be a permanent install location for supporting dependencies needed before we can build nix itself.
We will also need these at this location to run nix once it's built. 

If you prefer, you can choose a location under `NIX_PREFIX` for PREFIX
  
If you can write to `/usr/local`, that might be a natural value for `PREFIX`.
You could also use `/usr` (if you have write permission there), but in that case would likely be 
fighting with the host operating system's package manager.

Optionally, edit `nix-from-scratch-${version}/mk/config.mk` to choose `ARCHIVE_DIR`
This location will store downloaded source tarballs for nix and its dependencies.
These will consume about 150MB.

3. Choose nix install location

Edit `nix-from-scratch-${version}/pkgs/nix/Makefile`, choose value for `NIX_PREFIX`.
Also adjust `NIX_STORE_DIR`, `NIX_LOCALSTATE_DIR`, `NIX_SYSCONF_DIR` if desired.
  
Summary:
  
  | variable             | default                 | purpose                                        |
  |----------------------|-------------------------|------------------------------------------------|
  | `PREFIX`             | `$HOME/ext`             | non-system root directory for nix dependencies |
  | `NIX_PREFIX`         | `$HOME/nixroot`         | non-system root directory for nix itself       |
  | `NIX_STORE_DIR`      | `$NIX_PREFIX/nix/store` | location for nix-built artifacts               |
  | `NIX_SYSCONF_DIR`    | `$NIX_PREFIX/etc`       | default user configuration files               |
  | `NIX_LOCALSTATE_DIR` | `$NIX_PREFIX/var`       | nix-generated logfiles                         |

4. Build and install supporting packages 

There are several dozen packages to build.  We will install each package under the same =PREFIX=.
Packages depend on each other, so order is important;  later packages rely on successful build+install
of earlier packages.

The toplevel `$srcdir/Makefile` has a target for each nix dependency,
and also knows inter-package dependencies. This allows it to enforce a consistent ordering.

```
cd $srcdir
make nix-deps    # recursively build+install all nix dependencies
```

5. Build and install nix itself

```
make pkgs/nix
```

### Package Versions

To see package versions (available with success unpack for each component):

```
cd $srcdir
cat pkgs/*/state/package-version
```

Output as of nix-from-scratch-0.37.0:
```
autoconf-archive-2023.02.20
autoconf-2.72
automake-1.17
bison-3.8.2
gc-8.2.6
boost-1.86.0
brotli-1.1.0
cmake-3.30.2
curl-8.9.1
editline-1.17.1
expat-2.6.2
flex-2.6.4
gperf-3.0.4
googletest-1.14.0
jq-1.7.1
libarchive-3.7.4
libcpuid-0.7.0
libgit2
libseccomp-2.5.5
libsodium-1.0.20
libssh2-1.11.0
libtool-2.4.7
libuv-v1.48.0
lowdown-1.1.0
m4-1.4.19
nix-2.24.9
json-3.11.3
openssl-3.3.1
patchelf-0.18.0
pkgconf-2.3.0
Python-3.12.6
rapidcheck
sqlite-autoconf-3460100
toml11-4.2.0
zlib-1.3.1
```

### Metabuild Organization

1. The build tracks build-lifecycle progress for each package *foo* in `$srcdir/pkgs/foo/state`.
This allows it to pickup 'where it left off' if a problem occurs, without having to know installed 
artifacts for a package.

We divide the build for each package into phases. All phases must complete before a package is considered
available as a dependency.

Phases:

| package | action                                | outputs                                           |
|---------|---------------------------------------|---------------------------------------------------|
| fetch   | fetch tarball, store in `ARCHIVE_DIR` | `fetch.result`                                    |
| verify  | verify sha256 vs package Makefile     | `verify.result` `actual.sha256` `expected.sha256` |
| unpack  | untar to pkgs/foo/src                 | `unpack.result` `package-version`                 |
| patch   | patch source tree if necessary        | `patch.result` `done.patch.sha256`                |
| config  | configure package's build system      | `config.result`                                   |
| compile | build package                         | `compile.result`                                  |
| install | install to `PREFIX`                   | `install.result`                                  |

2. For each package there are special 'manual do-over' targets to reset build for that package 
to a known state:

| target       | destination state                                 |
|--------------|---------------------------------------------------|
| distclean    | initial state (before fetch)                      |
| verifyclean  | just before verify phase (before checking sha256) |
| unpackclean  | just before unpack phase (before untar)           |
| configclean  | just before config phase                          |
| clean        | just before compile phase                         |
| installclean | just before install phase                         |

3. Building individual packages -- ignoring dependencies

Each package *foo* has its own `Makefile` in `$srcdir/pkgs/foo/Makefile`.
That `Makefile` expects any upstream dependencies to have already been built+installed under `PREFIX`.

To build an individual package, say `m4`:

```
cd $srcdir/pkgs/m4
make
```

4. Dependency order

List of all packages, sorted so that depended-on packages appear before packages that rely on them.

| package          |
|------------------|
| m4               |
| autoconf         |
| autoconf-archive |
| automake         |
| libtool          |
| libcpuid         |
| zlib             |
| pkgconf          |
| sqlite           |
| openssl          |
| curl-stage1      |
| expat            |
| libarchive       |
| libuv            |
| cmake            |
| patchelf         |
| brotli           |
| curl-stage2      |
| nlohmann_json    |
| jq               |
| python           |
| boost            |
| editline         |
| libsodium        |
| gperf            |
| libseccomp       |
| boehm-gc         |
| gtest            |
| rapidcheck       |
| libssh2          |
| libgit2          |
| toml11           |
| flex             |
| bison            |
| lowdown          |
| nix              |

5. Building packages -- dependencies first

Can also use top-level `Makefile` to build a supporting package and its dependencies:

```
cd $srcdir
make pkgs/jq
```

Builds and installs `m4` -> `autoconf` -> `jq`

### Filesystem organization

```
nix-from-scratch-0.37.0
+- Makefile              umbrella makefile; delegates to pkgs/foo/Makefile for each package
+- README.md
+- LICENSE
+- archive               directory for source tarballs
|  +- foo-1.2.3.tar.gz
|  ...
+- mk                    helper makefiles/scripts to abstract common patterns
\- pkgs                  parent for package-specific directories
   +- foo
   |   +- Makefile       makefile for a single package foo
   |   +- foo-1.2.3      unpacked source directory for package foo
   |   \- state          track build phase results
   +- bar
   |   +- Makefile
   |   +- bar-4.5.6
   |   \- state
   .
   .
   
```

`pkgs` contains one subdirectory for nix itself, plus one subdirectory for each package that nix depends on.
The set of pacakges is sufficient to build nix on a stock ubuntu platform (e.g. 22.04/jammy).
This assumes the base platform provides working (and sufficiently new) c and c++ compilers.

### Troubleshooting

Anticipated problems:

1. Version problem in some `/usr` dependency.

Best fix is probably to add the offending dependency to nix-from-scratch.  
Suggest combining information from:

(a) some existing nix-from-scratch package (for Makefile),
(b) linuxfromscratch instructions (for build instructions), 
(c) nixpkgs default.nix (for build instructions) for that package

2. Host compiler toolchain too old

This project assumes host already has adequate c and c++ compilers.
If this is not the case, one path is to build and install those too.

I've found linuxfrom scratch (https://www.linuxfromscratch.org) most useful
for detailed executable build instructions.

As of Oct 2024, LFS build instructions for gcc 14.2 are here:
https://www.linuxfromscratch.org/lfs/view/12.2/chapter08/gcc.html

Note that you probably have to modify these to work with a `PREFIX` directory that isn't visited by `ldconfig`.
May be able to use the `cflags` and `ldflags` variables from `$srcdir/pkgs/*/Makefile` as a starting point

3. Host libc is too old

Symptom: build complains about missing symbols wich LIBC in their name

More painful than compiler toolchain too old. It's possible to build+install libc to a non-standard location;
linuxfromscratch is again a useful guide. If you have to go down this path, know that a linux executable can only
use a single libc. Should you prepare a custom libc, you'll likely need to provide custom versions of most 
everything else in `/usr` to go with it.


