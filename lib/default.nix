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
            // (import (dir + /custom.nix))
            // { inherit hostname; };
      username = custom.username;
      intermediary = specialArgs // { inherit inputs custom; };
    in
      let
        specialArgs = intermediary;
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
          ${if ssh-uri != null then "$DRY_RUN_CMD ${git-cmd} remote $VERBOSE_ARG set-url origin ${ssh-uri}" else ""}
          $DRY_RUN_CMD ${git-cmd} pull $VERBOSE_ARG || true
        $DRY_RUN_CMD popd
      fi
    '';

}
