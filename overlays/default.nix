{ inputs, pkgs-stable, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      nsxiv = prev.nsxiv.overrideAttrs (old: {
        postInstall = # bash
          ''
            sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
          '';
      });

      copyq = pkgs-stable.copyq; # https://github.com/NixOS/nixpkgs/pull/398926
    })

    inputs.jujutsu.overlays.default
  ];
}
