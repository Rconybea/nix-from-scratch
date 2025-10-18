# ultra minimal substitute for nixpkgs.lib.buildEnv
#
# Main advantage is that it only uses builtins, with no other dependencies
#
# Disadvantages include:
# - doesn't handle subdirectories
# - silently swallows collisions
# - no support for explicit priorities
# - will not create empty directories
#
# Use:
#   let
#     buildEnv = import ./buildenv.nix;
#   in
#     buildEnv { name = "my-env";
#                paths = [ gcc binutils coreutils ];
#                pathsToLink = "/bin"
#              };
#
{ name,
  paths,
  pathsToLink ? ["/"],
  coreutils
} :

derivation {
  inherit name;
  system = builtins.currentSystem;

  PATH = "${coreutils}/bin";

  # dash
  builder = "/bin/sh";

  args = [ "-e"
           (builtins.toFile
             "buildenv-builder.sh"
             ''
               #set -x

               mkdir -p "$out"

               link_dir() {
                 local src="$1"
                 local dst="$2"

                 [ -d "$src" ] || return

                 echo "create directory [$dst]"
                 mkdir -p "$dst"

                 for item in "$src"/*; do
                   [ -e "$item" ] || continue

                   local name=$(basename "$item")
                   local target="$dst/$name"

                   if [ -d "$item" ] && [ ! -L "$item" ]; then
                     # recurse into ordinary non-symlink directories
                     if [ -e "$target" ] || [ -L "$target" ]; then
                       if [ -d "$target" ] && [ ! -L "$target" ]; then
                         # parallel directories under both $src and $dst -> recurse
                         #
                         link_dir "$item" "$target"
                       fi
                     else
                       # $target doesn't exist yet.  recurse to populate
                       link_dir "$item" "$target"
                     fi
                   else
                     # file or symlink -- create directy symlink under $dst
                     [ -e "$target" ] || [ -L "$target" ] || ln -s "$item" "$target"
                   fi
                 done
               }

               for path in "$@"; do
                 [ -d "$path" ] || continue

                 for linkPath in ${builtins.toString pathsToLink}; do
                   #mkdir -p $out/$linkPath

                   [ "$linkPath" = "/" ] && linkPath=""
                   src="$path$linkPath"
                   dst="$out$linkPath"

                   link_dir "$src" "$dst"
                 done
               done
             '')
         ] ++ paths;

  preferLocalBuild = true;
}
