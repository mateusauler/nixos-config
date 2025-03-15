{ pkgs-stable, ... }:

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

      htop-vim = pkgs-stable.htop-vim; # https://github.com/NixOS/nixpkgs/issues/389663
      wireplumber = pkgs-stable.wireplumber; # https://github.com/NixOS/nixpkgs/issues/389656
      rustdesk-flutter = pkgs-stable.rustdesk-flutter; # https://github.com/NixOS/nixpkgs/issues/389638
    })
  ];
}
