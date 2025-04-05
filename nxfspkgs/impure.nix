let
  # homeDir :: string
  homeDir = builtins.getEnv "HOME";

  # isDir :: string|path -> bool
  isDir = (path : builtins.pathExists path + "/.");

  # pathIfExists :: string|path -> bool
  pathIfExists = (d : if (d != "") && (builtins.pathExists d) then d else "");

  # pathifExists2 (builtins.getEnv "HOME") ".config"
  #  =>  HOME/.config when that path exists; "" otherwise
  #
  # pathIfExists2 :: string|path -> string|path -> bool
  pathIfExists2 = (x :
    let
      validx = pathIfExists x;
    in
      (y :
        if (validx != "")
        then
          pathIfExists (validx + y)
        else
          ""));

  # leftPath :: string -> string -> string
  leftPath = (x : y : if ((x != "") && (builtins.pathExists x)) then x else y);
in

let
  # configDir0 :: string
  configDir0 = pathIfExists (builtins.getEnv "XDG_CONFIG_HOME");
in

{
  # configuration for nxfspkgs
  #   NXFSPKGS_CONFIG
  #    > XDG_CONFIG_HOME/nxfspkgs/config.nix
  #    > HOME/.config/nxfspkgs/config.nix
  #    > HOME/.nxfspkgs/config.nix
  #
  # This is great scaffolding, but there are no nxfspkgs-specific configuration features yet.
  config ?
  let
    # configFile1 :: string
    configFile1 = pathIfExists (builtins.getEnv "NXFSPKGS_CONFIG");
    # configFile2 :: string
    configFile2 = pathIfExists2 (builtins.getEnv "XDG_HOME") "/nxfspkgs/config.nix";
    # configFile3 :: string
    configFile3 = pathIfExists2 homeDir "/.config/nxfspkgs/config.nix";
    # configFile4 :: string
    configFile4 = pathIfExists2 homeDir "/.nxfspkgs/config.nix";
  in
    let
      # config :: string
      cfgfile = (leftPath configFile1 (leftPath configFile2 configFile3));
    in
      if (cfgfile != "") && (builtins.pathExists cfgfile)
      then
        import cfgfile
      else
        {}


, # overlays allow extending nxfspkgs with additional package collections.
  #
  overlays ?
  let
    # [try X] is: the value of X whenever X evaluates; Y otherwise
    #
    # try :: T -> U -> T|U
    try = (x: y: let res = builtins.tryEval x;
                 in  if res.success
                     then res.value
                     else y);
  in
    let
      # overlays1 :: string
      overlaysDir1 = try (toString <nxfspkgs-overlays>) "";
      # overlaysFile1 :: string   #
      overlaysFile1 = pathIfExists2 (builtins.getEnv "XDG_HOME") "/nxfspkgs/overlays.nix";
      # overlaysFile2 :: string   # file containing overlays
      overlaysFile2 = pathIfExists2 homeDir "/.config/nxfspkgs/overlays.nix";
      # overlaysDir2 :: string   # directory with additional overlays
      overlaysDir2 = pathIfExists2 homeDir "/.config/nxfspkgs/overlays";
    in
      let
        # overlaysFile :: string
        overlaysFile = leftPath overlaysFile1 overlaysFile2;

        # overlaysDir :: string
        overlaysDir = leftPath overlaysDir1 overlaysDir2;

        # overlays :: path ->
        scanOverlaysFrom =
          (path :
            if isDir path
            then
              # path isa directory. Take from directory:
              #   d/foo.nix
              #   d/foo     when d/foo/default.nix exists
              let
                # content :: array(string)  # contents of path/
                content = builtins.readDir path;
              in
                map (n : import (path + ("/" + n)))
                  (builtins.filter
                    (n :
                      ((builtins.match ".*\\.nix" n) != null
                       && (builtins.match "\\.#.*" n) == null) # skip emacs lock files, ugh
                      || builtins.pathExists (path + ("/" + n + "/default.nix")))
                    (builtins.attrNames content))
            else
              # path isa file, import it
              import path);
      in
        if (pathIfExists overlaysDir != "")
        then
           if (isDir overlaysDir)
           then
             scanOverlaysFrom overlaysDir
           else
             throw ''
             File [${overlaysDir}] found where directory expected
             ''
        else
          if builtins.pathExists overlaysFile1 && builtins.pathExists overlaysFile2
          then
            throw ''
            Can use File [${overlaysFile1}], or File [${overlaysFile2}], but not both.
            Must move one out of the way (you're welcome).
            ''
          else
            if builtins.pathExists overlaysFile
            then
              if isDir overlaysFile
              then
                throw ''
                Dir [${overlaysFile}] found where file expected
                ''
              else
                import overlaysFile
            else
              {}

, ...
} @ args:

# all the attributes from args (command line arguments);
# with substitutions from {config, overlays}
#
import ./nxfspkgs.nix (args // { config = { contentAddressedByDefault = false; } // config;
                                 inherit overlays; })
