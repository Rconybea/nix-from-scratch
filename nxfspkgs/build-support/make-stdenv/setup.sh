#!/bin/bash
#
# Primitive version of nixpkgs setup.sh
# See nixpkgs/pkgs/stdenv/generic/setup.sh
#
# Incoming variables (from ./default.nix, for example)
#   initialPath
#   baseInputs
#   buildInputs
#   nativeBuildInputs
#   propagatedBuildInputs
#
# make-stdenv.nix defines various defaultXxx variables.
# this setup.sh file never references those.
# They exist so that .nix files can refer to them.
#
# ../make-derivation/make-derivation.nix arranges default
# derivation attrset with:
#   nativeBuildInputs = nativeBuildInputs ++ stdenv.defaultNativeBuildInputs
#   buildInputs = buildInputs ++ stdenv.defaultBuildInputs
# That way individual packages are free to override


set -e
set -u
set -o pipefail

# xxxHooks. These are bash arrays;
#
# A package can append Packages can append to such arrays
# to arrange for some bash code to run whenever package appears
# as a direct build dependency.
#
# Hook function will be invoked with no arguments.
#
# Any configurable behavior controlled through "secret agreement"
# global bash variables.
#
# For example the strip setup hook uses dontStrip, STRIP, RANLIB, etc.
#

# fixupOutputHooks: invoked once for each named top-level output directory
# e.g. $out, $dev, ...
#
declare -a fixupOutputHooks postUnpackHooks unpackCmdHooks

echo initialPath=${initialPath:-UNSET}

# Identical to nixLog, but additionally prefixed by the logLevel.
# NOTE: This function is only every meant to be called from the nix*Log family of functions.
_nixLogWithLevel() {
  # Return a value explicitly instead of the implicit return of the last command (result of the test).
  # NOTE: By requiring NIX_LOG_FD be set, we avoid dumping logging inside of nix-shell.
  [[ -z ${NIX_LOG_FD-} || ${NIX_DEBUG:-0} -lt ${1:?} ]] && return 0

  local logLevel
  case "${1:?}" in
  0) logLevel=ERROR ;;
  1) logLevel=WARN ;;
  2) logLevel=NOTICE ;;
  3) logLevel=INFO ;;
  4) logLevel=TALKATIVE ;;
  5) logLevel=CHATTY ;;
  6) logLevel=DEBUG ;;
  7) logLevel=VOMIT ;;
  *)
    echo "_nixLogWithLevel: called with invalid log level: ${1:?}" >&"$NIX_LOG_FD"
    return 1
    ;;
  esac

  # Use the function name of the caller, unless it is _callImplicitHook, in which case use the name of the hook.
  # NOTE: Our index into FUNCNAME is 2, not 1, because we are only ever to be called from the nix*Log family of
  # functions, never directly.
  local callerName="${FUNCNAME[2]}"
  if [[ $callerName == "_callImplicitHook" ]]; then
    callerName="${hookName:?}"
  fi

  # Use the function name of the caller's caller, since we should only every be invoked by nix*Log functions.
  printf "%s: %s: %s\n" "$logLevel" "$callerName" "${2:?}" >&"$NIX_LOG_FD"
}

# All provided arguments are joined with a space then directed to $NIX_LOG_FD, if it's set.
# Corresponds to `Verbosity::lvlTalkative` in the Nix source.
nixTalkativeLog() {
  _nixLogWithLevel 4 "$*"
}

# Log a hook, to be run before the hook is actually called.
# logging for "implicit" hooks -- the ones specified directly
# in derivation's arguments -- is done in _callImplicitHook instead.
_logHook() {
    # Fast path in case nixTalkativeLog is no-op.
    if [[ -z ${NIX_LOG_FD-} ]]; then
        return
    fi

    local hookKind="$1"
    local hookExpr="$2"
    shift 2

    if declare -F "$hookExpr" > /dev/null 2>&1; then
        nixTalkativeLog "calling '$hookKind' function hook '$hookExpr'" "$@"
    elif type -p "$hookExpr" > /dev/null; then
        nixTalkativeLog "sourcing '$hookKind' script hook '$hookExpr'"
    elif [[ "$hookExpr" != "_callImplicitHook"* ]]; then
        # Here we have a string hook to eval.
        # Join lines onto one with literal \n characters unless NIX_DEBUG >= 5.
        local exprToOutput
        if [[ ${NIX_DEBUG:-0} -ge 5 ]]; then
            exprToOutput="$hookExpr"
        else
            # We have `r'\n'.join([line.lstrip() for lines in text.split('\n')])` at home.
            local hookExprLine
            while IFS= read -r hookExprLine; do
                # These lines often have indentation,
                # so let's remove leading whitespace.
                hookExprLine="${hookExprLine#"${hookExprLine%%[![:space:]]*}"}"
                # If this line wasn't entirely whitespace,
                # then add it to our output
                if [[ -n "$hookExprLine" ]]; then
                    exprToOutput+="$hookExprLine\\n "
                fi
            done <<< "$hookExpr"

            # And then remove the final, unnecessary, \n
            exprToOutput="${exprToOutput%%\\n }"
        fi
        nixTalkativeLog "evaling '$hookKind' string hook '$exprToOutput'"
    fi
}

# Run all hooks with the specified name, until one succeeds (returns a
# zero exit code). If none succeed, return a non-zero exit code.
runOneHook() {
    local hookName="$1"
    shift
    local hooksSlice="${hookName%Hook}Hooks[@]"

    local hook ret=1
    # Hack around old bash like above
    for hook in "_callImplicitHook 1 $hookName" ${!hooksSlice+"${!hooksSlice}"}; do
        _logHook "$hookName" "$hook" "$@"
        if _eval "$hook" "$@"; then
            ret=0
            break
        fi
    done

    return "$ret"
}


# Run the named hook, either by calling the function with that name or
# by evaluating the variable with that name. This allows convenient
# setting of hooks both from Nix expressions (as attributes /
# environment variables) and from shell scripts (as functions). If you
# want to allow multiple hooks, use runHook instead.
_callImplicitHook() {
    local def="$1"
    local hookName="$2"
    if declare -F "$hookName" > /dev/null; then
        nixTalkativeLog "calling implicit '$hookName' function hook"
        "$hookName"
    elif type -p "$hookName" > /dev/null; then
        nixTalkativeLog "sourcing implicit '$hookName' script hook"
        source "$hookName"
    elif [ -n "${!hookName:-}" ]; then
        nixTalkativeLog "evaling implicit '$hookName' string hook"
        eval "${!hookName}"
    else
        return "$def"
    fi
    # `_eval` expects hook to need nounset disable and leave it
    # disabled anyways, so Ok to to delegate. The alternative of a
    # return trap is no good because it would affect nested returns.
}


# A function wrapper around ‘eval’ that ensures that ‘return’ inside
# hooks exits the hook, not the caller. Also will only pass args if
# command can take them
_eval() {
    if declare -F "$1" > /dev/null 2>&1; then
        "$@" # including args
    else
        eval "$1"
    fi
}


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

for i in ${propagatedBuildInputs} ${buildInputs} ${nativeBuildInputs} ${baseInputs}; do
    findInputs $i
done

echo "pkgs=${pkgs}"

for i in $pkgs; do
    if [[ -d ${i} ]]; then
        # dependency is a directory (output of some derivation):
        # - source its setup hook
        # - add its bin directory to PATH
        # - add appropriate paths to _PKG_CONFIG_PATH, _NIX_CFLAGS_COMPILE, _NIX_LDFLAGS
        #   (perhaps others later)

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
    elif [[ -f ${i} ]]; then
        # plain old text file (which had better be a bash script).
        # execute it immediately
        source ${i}
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

# Utility function: echo the base name of the given path, with the
# prefix `HASH-' removed, if present.
stripHash() {
    local strippedName casematchOpt=0
    # On separate line for `set -e`
    strippedName="$(basename -- "$1")"
    shopt -q nocasematch && casematchOpt=1
    shopt -u nocasematch
    if [[ "$strippedName" =~ ^[a-z0-9]{32}- ]]; then
        echo "${strippedName:33}"
    else
        echo "$strippedName"
    fi
    if (( casematchOpt )); then shopt -s nocasematch; fi
}


unpackCmdHooks+=(_defaultUnpack)
_defaultUnpack() {
    local fn="$1"
    local destination

    if [ -d "$fn" ]; then

        destination="$(stripHash "$fn")"

        if [ -e "$destination" ]; then
            echo "Cannot copy $fn to $destination: destination already exists!"
            echo "Did you specify two \"srcs\" with the same \"name\"?"
            return 1
        fi

        # We can't preserve hardlinks because they may have been
        # introduced by store optimization, which might break things
        # in the build.
        cp -r --preserve=mode,timestamps --reflink=auto -- "$fn" "$destination"

    else

        case "$fn" in
            *.tar.xz | *.tar.lzma | *.txz)
                # Don't rely on tar knowing about .xz.
                # Additionally, we have multiple different xz binaries with different feature sets in different
                # stages. The XZ_OPT env var is only used by the full "XZ utils" implementation, which supports
                # the --threads (-T) flag. This allows us to enable multithreaded decompression exclusively on
                # that implementation, without the use of complex bash conditionals and checks.
                # Since tar does not control the decompression, we need to
                # disregard the error code from the xz invocation. Otherwise,
                # it can happen that tar exits earlier, causing xz to fail
                # from a SIGPIPE.
                (XZ_OPT="--threads=$NIX_BUILD_CORES" xz -d < "$fn"; true) | tar xf - --mode=+w --warning=no-timestamp
                ;;
            *.tar | *.tar.* | *.tgz | *.tbz2 | *.tbz)
                # GNU tar can automatically select the decompression method
                # (info "(tar) gzip").
                tar xf "$fn" --mode=+w --warning=no-timestamp
                ;;
            *)
                return 1
                ;;
        esac

    fi
}


unpackFile() {
    curSrc="$1"
    echo "unpacking source archive $curSrc"
    if ! runOneHook unpackCmd "$curSrc"; then
        echo "do not know how to unpack source archive $curSrc"
        exit 1
    fi
}

unpackPhase() {
    # runHook preUnpack

    if [ -z "${srcs:-}" ]; then
        if [ -z "${src:-}" ]; then
            # shellcheck disable=SC2016
            echo 'expect variable $src or $srcs to point to the source'
            exit 1
        fi
        srcs=${src}
    fi

    local -a srcsArray
    #concatTo srcsArray srcs
    srcsArray+=( $srcs )  # crippled impl. only works if one element.

    # To determine the source directory created by unpacking the
    # source archives, we record the contents of the current
    # directory, then look below which directory got added.  Yeah,
    # it's rather hacky.
    local dirsBefore=""
    for i in *; do
        if [ -d "$i" ]; then
            dirsBefore="$dirsBefore $i "
        fi
    done

    for i in "${srcsArray[@]}"; do
        unpackFile "$i"
    done

    # Find the source directory.

    # set to empty if unset
    : "${sourceRoot=}"

    if [ -n "${setSourceRoot:-}" ]; then
        runOneHook setSourceRoot
    elif [ -z "$sourceRoot" ]; then
        for i in *; do
            if [ -d "$i" ]; then
                case $dirsBefore in
                    *\ $i\ *)
                        ;;
                    *)
                        if [ -n "$sourceRoot" ]; then
                            echo "unpacker produced multiple directories"
                            exit 1
                        fi
                        sourceRoot="$i"
                        ;;
                esac
            fi
        done
    fi

    if [ -z "$sourceRoot" ]; then
        echo "unpacker appears to have produced no directories"
        exit 1
    fi

    echo "source root is $sourceRoot"

    # By default, add write permission to the sources.  This is often
    # necessary when sources have been copied from other store
    # locations.
    if [ "${dontMakeSourcesWritable:-0}" != 1 ]; then
        chmod -R u+w -- "$sourceRoot"
    fi

    # runHook postUnpack
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
    # For each output (like $out, $dev, $doc, etc.)
    for output in $outputs; do
        prefix="${!output}"

        # Run all registered fixup hooks
        for hook in "${fixupOutputHooks[@]}"; do
            $hook
        done
    done

    # generate $out/nix-support/propagated-build-inputs
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
