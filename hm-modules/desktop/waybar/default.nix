{
  config,
  lib,
  nixpkgs-channel,
  pkgs,
  ...
}:

let
  cfg = config.modules.waybar;
in
{
  options.modules.waybar = with lib.options; {
    enable = mkEnableOption "Waybar";
    battery.enable = mkEnableOption "Battery";
    extra-modules =
      let
        modules =
          group:
          mkOption {
            description = "Modules to be added to the ${group} group";
            type =
              with lib.types;
              listOf (submodule {
                options = {
                  position = mkOption {
                    description = "Position relative to the reference modules";
                    type = enum [
                      "before"
                      "after"
                    ];
                    default = "before";
                  };
                  reference-modules = mkOption {
                    description = "Modules to be used as reference for placement";
                    type = oneOf [
                      (listOf str)
                      str
                    ];
                    apply = lib.toList;
                  };
                  module-names = mkOption {
                    description = "Modules to be added";
                    type = oneOf [
                      (listOf str)
                      str
                    ];
                    apply = lib.toList;
                  };
                };
              });
            default = [ ];
          };
      in
      mkOption {
        type =
          with lib.types;
          submodule {
            options = {
              left = modules "left";
              center = modules "center";
              right = modules "right";
            };
          };
        default = {
          left = [ ];
          center = [ ];
          right = [ ];
        };
      };
  };

  imports = [
    ./settings.nix
    ./style.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = if nixpkgs-channel == "unstable" then pkgs.waybar-git else pkgs.waybar;
    };
  };
}
