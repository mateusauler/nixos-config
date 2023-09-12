{ config, lib, pkgs, specialArgs, ... }:

let
  cfg = config.modules.ferdium;
  pkg = pkgs.ferdium.overrideAttrs (old: lib.attrsets.optionalAttrs config.modules.hyprland.enable {
      postFixup = ''
        ${old.postFixup}
        sed -i -E "s/Exec=ferdium/Exec=ferdium --enable-features=UseOzonePlatform --ozone-platform=wayland/" $out/share/applications/ferdium.desktop
      '';
    }
  );

in {
  options.modules.ferdium.enable = lib.mkEnableOption "ferdium";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkg ];
  };
}
