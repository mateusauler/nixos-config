{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      satisfactory-mod-manager = final.callPackage ./smm.nix { };

      ferdium-wayland = prev.ferdium.overrideAttrs (old: {
        postFixup = # bash
          ''
            ${old.postFixup}
            sed -i -E "s/Exec=ferdium/Exec=ferdium --enable-features=UseOzonePlatform --ozone-platform=wayland/" $out/share/applications/ferdium.desktop
          '';
      });

      nsxiv = prev.nsxiv.overrideAttrs (old: {
        postInstall = # bash
          ''
            sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
          '';
      });

      # Fix broken package until https://github.com/NixOS/nixpkgs/pull/380251 lands on unstable
      qogir-icon-theme = prev.qogir-icon-theme.overrideAttrs (old: {
        dontCheckForBrokenSymlinks = true;
      });
    })
  ];
}
