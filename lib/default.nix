{ lib, pkgs, ... }:

{
  readDirNames = path:
    builtins.attrNames
      (lib.filterAttrs
        (_: type: type == "directory")
        (builtins.readDir path)
      );

  getUsers = lib.foldl' (acc: u: acc // { ${u} = import ../users/${u}; }) { } (lib.readDirNames ../users);

  mkNixosSystem = { hostname, system, inputs, pkgs, specialArgs ? { }, customDefaults ? { }, ... }:
    let
      inherit (inputs) home-manager nixpkgs;

      dir = ../hosts + "/${hostname}";
      custom = customDefaults
        // import (dir + /custom.nix)
        // { inherit hostname; };
      username = custom.username;
      specialArgs' = specialArgs // { inherit inputs custom; };
    in
    nixpkgs.lib.nixosSystem rec {
      # TODO: Look into replacing system with localSystem
      #       Suggested here: https://discordapp.com/channels/568306982717751326/741347063077535874/1140546315990859816
      inherit system pkgs;

      specialArgs = specialArgs';

      modules = [
        (dir + /configuration.nix)
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            users = lib.mapAttrs (_: _: import (dir + /home.nix)) lib.getUsers;
            useGlobalPkgs = true;
            useUserPackages = false;
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };

  cloneRepo = { path, url, ssh-uri ? null }:
    let
      git = "${pkgs.git}/bin/git";
    in
    ''
      if [ ! -d ${path} ]; then
        $DRY_RUN_CMD ${git} clone $VERBOSE_ARG ${url} ${path}
        $DRY_RUN_CMD pushd ${path}
          ${lib.optionalString (ssh-uri != null) "$DRY_RUN_CMD ${git} remote $VERBOSE_ARG set-url origin ${ssh-uri}"}
          $DRY_RUN_CMD ${git} pull $VERBOSE_ARG || true
        $DRY_RUN_CMD popd
      fi
    '';

  enableModules = module-names:
    let
      join-modules = acc: mod:
        let
          path = (lib.strings.splitString "." mod) ++ [ "enable" ];
        in
          lib.recursiveUpdate acc (lib.attrsets.setAttrByPath path (lib.mkDefault true));
    in
    (builtins.foldl' join-modules { } module-names);

  mkTrueEnableOption = name: lib.mkEnableOption name // { default = true; };

  fromHex = str:
    let
      hexChars = lib.strings.stringToCharacters "0123456789ABCDEF";

      toInt = c: lib.lists.findFirstIndex (x: x == c) (throw "invalid hex digit: ${c}") hexChars;
      accumulate = a: c: a * 16 + toInt c;

      strU = lib.strings.toUpper str;
      chars = lib.strings.stringToCharacters strU;
    in
    builtins.foldl' accumulate 0 chars;

  colorToIntList = color:
    let
      colorsChr = lib.strings.stringToCharacters color;
      colorsSep = lib.strings.concatImapStrings (pos: c: if (lib.trivial.mod pos 2 == 0) then c + " " else c) colorsChr;
      colorsHexDirty = lib.strings.splitString " " colorsSep;
      colorsHex = lib.lists.remove "" colorsHexDirty;
    in
    builtins.map lib.fromHex colorsHex;

  colorToRgba = color: alpha:
    let
      colorsNum = lib.colorToIntList color;
      colorsB10 = builtins.map toString colorsNum;
      colorsStr = builtins.concatStringsSep "," colorsB10;
    in
    "rgba(" + colorsStr + ",${toString alpha})";

}
