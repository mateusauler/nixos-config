{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      git-worktree-switcher = final.callPackage ./wt { src = inputs.git-worktree-switcher; };
      satisfactory-mod-manager = final.callPackage ./smm.nix { };
    })

    (final: prev: {
      ferdium-wayland = prev.ferdium.overrideAttrs (old: {
        postFixup = # bash
          ''
            ${old.postFixup}
            sed -i -E "s/Exec=ferdium/Exec=ferdium --enable-features=UseOzonePlatform --ozone-platform=wayland/" $out/share/applications/ferdium.desktop
          '';
      });
    })

    (final: prev: {
      nsxiv = prev.nsxiv.overrideAttrs (old: {
        postInstall = # bash
          ''
            sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
          '';
      });
    })

    (final: prev: {
      vimPlugins = prev.vimPlugins // {
        eyeliner-nvim = prev.vimPlugins.eyeliner-nvim.overrideAttrs (old: {
          src = inputs.eyeliner-nvim;
        });
      };
    })
  ];
}
