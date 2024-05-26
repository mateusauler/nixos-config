{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.nsxiv;
  pkg = pkgs.nsxiv.overrideAttrs (old: {
    postInstall = # bash
      ''
        sed -iE "s/Exec\\s*=\\s*nsxiv\\s*\\(.*\\)$/Exec=nsxiv -a \\1/" $out/share/applications/nsxiv.desktop
      '';
  });
in
{
  options.modules.nsxiv.enable = lib.mkEnableOption "nsxiv";

  config = lib.mkIf cfg.enable { home.packages = [ pkg ]; };
}
