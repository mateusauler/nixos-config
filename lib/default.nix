{ lib, pkgs, ... }:

{
  readDirNames = path:
    builtins.attrNames
      (lib.filterAttrs
        (_: type: type == "directory")
        (builtins.readDir path)
      );

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
      let
        specialArgs = specialArgs';
      in nixpkgs.lib.nixosSystem {
        # TODO: Look into replacing system with localSystem
        #       Suggested here: https://discordapp.com/channels/568306982717751326/741347063077535874/1140546315990859816
        inherit system pkgs specialArgs;

        modules = [
          (dir + /configuration.nix)
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${username} = import (dir + /home.nix);
              useGlobalPkgs = true;
              useUserPackages = false;
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };

  cloneRepo = { path, url, ssh-uri ? null }:
    let
      git-cmd = "${pkgs.git}/bin/git";
    in ''
      if [ ! -d ${path} ]; then
        $DRY_RUN_CMD ${git-cmd} clone $VERBOSE_ARG ${url} ${path}
        $DRY_RUN_CMD pushd ${path}
          ${lib.optionalString (ssh-uri != null) "$DRY_RUN_CMD ${git-cmd} remote $VERBOSE_ARG set-url origin ${ssh-uri}"}
          $DRY_RUN_CMD ${git-cmd} pull $VERBOSE_ARG || true
        $DRY_RUN_CMD popd
      fi
    '';

  enableModules = { module-names, other-options ? { } }:
    let
      join-modules = acc: m: acc // { ${m}.enable = lib.mkDefault true; };
      enabled-modules = (builtins.foldl' join-modules { } module-names);
    in
      lib.attrsets.recursiveUpdate enabled-modules other-options;

  mkTrueEnableOption = name: lib.mkEnableOption name // { default = true; };

}
