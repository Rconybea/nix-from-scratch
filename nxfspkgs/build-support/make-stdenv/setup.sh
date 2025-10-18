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

# append $1/bin to _PATH (at the end)
addToEnv() {
    if [[ -d $1/bin ]]; then
        eval export _PATH=${_PATH-}${_PATH:+:}$1/bin
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

for i in $pkgs; do
    addToEnv ${i}

    if [[ -d ${i}/lib/pkgconfig ]]; then
        eval export _PKG_CONFIG_PATH=${_PKG_CONFIG_PATH-}${_PKG_CONFIG_PATH:+:}${i}/lib/pkgconfig
    fi
done
PATH="${_PATH-}${_PATH:+${PATH:+:}}$PATH"
PKG_CONFIG_PATH="${_PKG_CONFIG_PATH-}${_PKG_CONFIG_PATH:+${PKG_CONFIG_PATH:+:}}$PKG_CONFIG_PATH"

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
