{
  inputs,
  nixpkgs-channel,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      nsxiv = prev.nsxiv.overrideAttrs (old: {
        postInstall = # bash
          ''
            sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
          '';
      });
    })
    (
      if (nixpkgs-channel == "unstable") then
        inputs.jujutsu.overlays.default
      else
        # Jujutsu package in stable is insecure
        (_: _: { inherit (pkgs-unstable) jujutsu lazyjj; })
    )
    (_: _: {
      waybar-git = inputs.waybar.packages.${pkgs.stdenv.hostPlatform.system}.waybar;
    })
  ];
}
