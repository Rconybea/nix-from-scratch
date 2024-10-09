![Build Status on github actions](https://github.com/Rconybea/nix-from-scratch/actions/workflows/main.yml/badge.svg)
![Build Status on github actions](https://github.com/Rconybea/nix-from-scratch/actions/workflows/dev.yml/badge.svg)
[![Version](https://img.shields.io/badge/prerelease-v0.22.0-blue)](https://github.com/Rconybea/nix-from-scratch/releases)
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

If so, may prefer to install nix dependencies from pacakge manager instead of building them
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

2. Install to a common but non-LSB location (`$HOME/ext`).
(Since premise is that we can't write to `/usr/bin` etc).

In particular, we assume that we're installing to a directory that `ldconfig` doesn't know about.
this means that in general, if (a) we have two libraries {L, M} installed `/path/to/foo`
(i.e. `$HOME/ext/lib`), and (b) L depends on M:
then L needs a `DT_RUNPATH` entry `/path/to/foo` so that loader can find M when it encounters L

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

### Build Instructions

1. Download release

```
curl -L https://github.com/Rconybea/nix-from-scratch/archive/refs/tags/nix-from-scratch-0.22.0.tar.gz
tar xf nix-from-scratch-0.22.0.tar.gz
```

### Filesystem organization

```
nix-from-scratch
+- Makefile              umbrella makefile; delegates to pkgs/foo/Makefile for each package
+- README.md
+- LICENSE
+- archive               directory for source tarballs
|  +- foo-1.2.3.tar.gz
|  ...
+- mk                    helper makefiles/scripts to abstract common patterns
\- pkgs                  parent for package-specific directories
   +- foo
       +- Makefile       makefile for a single package foo
       +- foo-1.2.3      unpacked source directory for package foo
       \- state          track build phase results
          ...
```

### Makefile organization

Each subproject (m4, automake, boost, etc) gets its own Makefile.
Makefile in root directory delgates to project Makefiles.
Toplevel Makefile also knows inter-project dependencies

Makefiles divide build into phases,  with state transitions shown here:

```

        /----distclean
        v
     (start)
        |
        |fetch
        |
        |/---verifyclean
        vv
       (s1)      [ok: empty state/fetch.result, $(tarball_path), log/wget.log]
        |
        |verify
        |
        |/---unpackclean
        vv
       (s2)      [ok: empty state/verify.result; state/*.sha256]
        |
        |unpack
        v
       (s3)
        |
        |patch
        v
       (s4)
        |
        |config
        |
        |/---clean
        vv
       (s5)
        |
        |compile
        v
       (s6)
        |
        |install
        v
     (finish)

```
