{ inputs, pkgs-stable, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      satisfactory-mod-manager = final.callPackage ./smm.nix { };

      nsxiv = prev.nsxiv.overrideAttrs (old: {
        postInstall = # bash
          ''
            sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
          '';
      });

      rustdesk-flutter = pkgs-stable.rustdesk-flutter; # https://github.com/NixOS/nixpkgs/issues/389638
    })

    inputs.jujutsu.overlays.default
  ];
}
