{
  inputs,
  lib,
  pkgs,
  private-config,
  ...
}:

{
  nixpkgs.overlays = lib.flatten [
    private-config.overlays
    (final: prev: {
      nsxiv = prev.nsxiv.overrideAttrs (old: {
        postInstall = # bash
          ''
            sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
          '';
      });
      waybar-git = inputs.waybar.packages.${prev.stdenv.hostPlatform.system}.waybar;
      niri-unstable = pkgs.symlinkJoin {
        inherit (prev.niri-unstable) name cargoBuildNoDefaultFeatures cargoBuildFeatures;
        paths = [ prev.niri-unstable ];
        postBuild = ''
          install -Dm755 "${./niri-session}" "$out/bin/niri-session"
        '';
      };
    })
  ];
}
