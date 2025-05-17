{
  inputs,
  lib,
  nixpkgs-channel,
  pkgs-unstable,
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

    (
      if (nixpkgs-channel == "unstable") then
        inputs.jujutsu.overlays.default
      else
        # Jujutsu package in stable is insecure
        (_: _: { inherit (pkgs-unstable) jujutsu lazyjj; })
    )
  ];
}
