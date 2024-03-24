{ config, lib, pkgs, specialArgs, ... }:

let
  cfg = config.modules.ferdium;
in
{
  options.modules.ferdium = {
    enable = lib.mkEnableOption "ferdium";
    # FIXME: There is a bug with the current ferdium version, when running with wayland enabled
    enableWayland = lib.mkEnableOption "running under Wayland" // { default = config.modules.hyprland.enable; };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        pkg = pkgs.ferdium.overrideAttrs (old: lib.attrsets.optionalAttrs cfg.enableWayland {
          postFixup = /* bash */ ''
            ${old.postFixup}
            sed -i -E "s/Exec=ferdium/Exec=ferdium --enable-features=UseOzonePlatform --ozone-platform=wayland/" $out/share/applications/ferdium.desktop
          '';
        }
        );
      in
      [ pkg ];
  };
}
