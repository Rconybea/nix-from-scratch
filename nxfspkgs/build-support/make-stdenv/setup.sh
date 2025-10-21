#!/bin/bash
#
# Primitive version of nixpkgs setup.sh
#
# Incoming variables (from ./default.nix, for example)
#   initialPath
#   baseInputs
#   buildInputs
#   propagatedBuildInputs
#

set -e
set -u
set -o pipefail

echo initialPath=${initialPath:-UNSET}

# 1. append $1/bin to _PATH (at the end)
# 2. source setup hook $1/nix-support/setup-hook
#
# remarks:
# 1. eval here allows RHS to refer to other variables
#
addToEnv() {
    echo "addToEnv: [$1]"

    if [[ -d $1/bin ]]; then
        eval export _PATH=${_PATH-}${_PATH:+:}$1/bin
    fi

    if [[ -f $1/nix-support/setup-hook ]]; then
        source "${i}/nix-support/setup-hook"
    fi
}

# nix-build supplied PATH doesn't point anywhere anyway

_PATH=

for i in ${initialPath}; do
    addToEnv ${i}
done

PATH=$_PATH
export PATH

CFLAGS=
export CFLAGS

LDFLAGS=
export LDFLAGS

#LD_LIBRARY_PATH=
#export LD_LIBRARY_PATH

PKG_CONFIG_PATH=
export PKG_CONFIG_PATH

# compile flags for (recursively enumerated) dependencies D
# that have a D/include subdirectory
#
_NIX_CFLAGS_COMPILE=
NIX_CFLAGS_COMPILE=
export NIX_CFLAGS_COMPILE

# linker flags for (recursively enumerated) dependencies D
# that have a D/lib subdirectory
#
_NIX_LDFLAGS=
NIX_LDFLAGS=
export NIX_LDFLAGS

declare pkgs=""

findInputs() {
    local pkg=$1

    case $pkgs in
        *\ $pkg\ *) # recognize is $pkgs already contains $pkg -> short-circuit
            return 0
            ;;
    esac

    pkgs="$pkgs $pkg "

    # also add propagated build inputs of $pkg
    if [[ -f ${pkg}/nix-support/propagated-build-inputs ]]; then
        for i in $(cat $pkg/nix-support/propagated-build-inputs); do
            findInputs $i
        done
    fi
}

for i in ${propagatedBuildInputs} ${buildInputs} ${baseInputs}; do
    findInputs $i
done

echo "pkgs=${pkgs}"

for i in $pkgs; do
    addToEnv ${i}

    if [[ -d ${i}/lib/pkgconfig ]]; then
        eval export _PKG_CONFIG_PATH=${_PKG_CONFIG_PATH:-}${_PKG_CONFIG_PATH:+:}${i}/lib/pkgconfig
    fi

    if [[ -d ${i}/include ]]; then
        eval export _NIX_CFLAGS_COMPILE=\"${_NIX_CFLAGS_COMPILE:-}${_NIX_CFLAGS_COMPILE:+ }-isystem ${i}/include\"
    fi

    if [[ -d ${i}/lib ]]; then
        eval export _NIX_LDFLAGS=\"${_NIX_LDFLAGS:-}${_NIX_LDFLAGS:+ }-L${i}/lib -Wl,-rpath,${i}/lib\"
    fi

done

# PATH, PKG_CONFIG_PATH, NIX_CFLAGS_COMPILE, NIX_LDFLAGS_COMPILE:
# 1. individual package builder can choose to override these.
# 2. underscore-prefixed values available in case package builder want to reference them
# 3. gcc wrappers automatically pass NIX_CFLAGS_COMPILE to compiler
#
PATH="${_PATH-}${_PATH:+${PATH:+:}}$PATH"
PKG_CONFIG_PATH="${_PKG_CONFIG_PATH:-}${_PKG_CONFIG_PATH:+${PKG_CONFIG_PATH:+:}}$PKG_CONFIG_PATH"
NIX_CFLAGS_COMPILE="${_NIX_CFLAGS_COMPILE:-}"
NIX_LDFLAGS="${_NIX_LDFLAGS:-}"

## copy drv.buildInputs, drv.derivation into PATH, in left-to-right order
#for dir in ${propagatedBuildInputs} ${buildInputs} ${baseInputs}; do
#    if [[ -d ${dir}/bin ]]; then
#        export PATH="${PATH}"${PATH:+:}${dir}/bin
#    fi
#
##    if [[ -d ${dir}/lib ]]; then
##        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"${LD_LIBRARY_PATH:+:}${dir}/lib
##    fi
#
#done

showPhaseHeader() {
    local phase="${1}"

    #echo "Running phase: ${phase}"

    if [[ -z ${NIX_LOG_FD-} ]]; then
        return
    fi

    # talk to handleJSONLogMessage in nixcpp source
    # e.g.
    #    @nix { "action": "setPhase", "phase": "build" }
    #
    printf "@nix { \"action\": \"setPhase\", \"phase\": \"%s\" }\n" "${phase}" >& ${NIX_LOG_FD-}
}

showPhaseFooter() {
    local phase="$1"
    local startTime="$2"
    local endTime="$3"
    local delta=$(( endTime - startTime ))

    # suppress message for builds taking < 30sec
    #(( delta < 30 )) && return

    local H=$((delta/3600))
    local M=$((delta%3600/60))
    local S=$((delta%60))
    printf "[%s] completed in [%02d:%02d:%02d]\n" ${phase} ${H} ${M} ${S}
}

unpackPhase() {
    :
}

patchPhase() {
    :
}

configurePhase() {
    :
}

buildPhase() {
    :
}

checkPhase() {
    :
}

installPhase() {
    :
}

fixupPhase() {
    if [[ -n "${propagatedBuildInputs}" ]]; then
        mkdir -p "${out}/nix-support"
        echo "${propagatedBuildInputs}" > "${out}/nix-support/propagated-build-inputs"
    fi
}

installCheckPhase() {
    :
}

distPhase() {
    :
}


runPhase() {
    showPhaseHeader "$curPhase"

    local startTime
    startTime=$(date +"%s")

    # $curPhase is either a variable or a function
    eval "${!curPhase:-$curPhase}"

    local endTime
    endTime=$(date +"%s")

    showPhaseFooter "$curPhase" "$startTime" "$endTime"

    if [[ ${curPhase} = unpackPhase ]]; then
        # make sure can cd into directory.
        # If present, will have been established by unpackPhase
        [[ -n "${sourceRoot:-}" ]] && chmod +x -- "${sourceRoot}"

        cd -- "${sourceRoot:-.}"
    fi
}

genericBuild() {
    # exclude yet another source of non-determinism
    export GZIP_NO_TIMESTAMPS=1

    # buildCommandPath ?

    if [[ -n "${buildCommand:-}" ]]; then
        # do buildCommand instead of rehearsing standard phases
        eval "${buildCommand:-}"
        return
    fi

    if [[ -n "${phases[*]:-}" ]]; then
        # do custom array of phases.
        # each member is either:
        # - name of a shell variable
        # - name of a shell function
        :
    else
        # default value for phases

        phases="${prePhases[*]:-} unpackPhase patchPhase \
          ${preConfigurePhases[*]:-} configurePhase \
          ${preBuildPhases[*]:-} buildPhase \
          checkPhase \
          ${preInstallPhases[*]:-} installPhase \
          ${preFixupPhases[*]:-} fixupPhase \
          installCheckPhase \
          ${preDistPhases[*]:-} distPhase \
          ${postPhases[*]:-}"
    fi

    for curPhase in ${phases[*]}; do
        runPhase "$curPhase"
    done
}

# postHook
# userHook
# dumpVars

# restore nix-shell options?
