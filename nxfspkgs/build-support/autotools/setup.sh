#!/bin/bash

set -e
set -u
set -o pipefail

# nix-build supplied PATH doesn't point anywhere anyway

PATH=
export PATH

CFLAGS=
export CFLAGS

LDFLAGS=
export LDFLAGS

#LD_LIBRARY_PATH=
#export LD_LIBRARY_PATH

PKG_CONFIG_PATH=
export PKG_CONFIG_PATH

# copy drv.buildInputs, drv.derivation into PATH, in left-to-right order
for dir in ${buildInputs} ${baseInputs}; do
    if [[ -d ${dir}/bin ]]; then
        export PATH="${PATH}"${PATH:+:}${dir}/bin
    fi

#    if [[ -d ${dir}/lib ]]; then
#        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"${LD_LIBRARY_PATH:+:}${dir}/lib
#    fi

    if [[ -d ${dir}/lib/pkgconfig ]]; then
        export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"${PKG_CONFIG_PATH:+:}${dir}/lib/pkgconfig
    fi
done


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
    :
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
