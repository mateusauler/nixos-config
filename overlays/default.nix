{
  inputs,
  lib,
  nixpkgs-channel,
  ...
}:

{
  nixpkgs.overlays = lib.flatten [
    (final: prev: {
      nsxiv = prev.nsxiv.overrideAttrs (old: {
        postInstall = # bash
          ''
            sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
          '';
      });
      waybar-git = inputs.waybar.packages.${prev.stdenv.hostPlatform.system}.waybar;
    })

    (lib.optional (nixpkgs-channel == "unstable") (
      final: prev: {
        inherit (import inputs.nixpkgs-pr-418461 { inherit (prev.stdenv.hostPlatform) system; })
          rocmPackages
          ;
      }
    ))
  ];
}
