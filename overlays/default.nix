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

    (lib.optionals (nixpkgs-channel == "unstable") [
      inputs.jujutsu.overlays.default

      # https://github.com/NixOS/nixpkgs/issues/412382#issuecomment-2924903019
      (final: prev: {
        mpv-unwrapped = prev.mpv-unwrapped.override {
          libplacebo = prev.libplacebo.overrideAttrs (old: rec {
            version = "7.349.0";
            src = prev.fetchFromGitLab {
              domain = "code.videolan.org";
              owner = "videolan";
              repo = "libplacebo";
              rev = "v${version}";
              hash = "sha256-mIjQvc7SRjE1Orb2BkHK+K1TcRQvzj2oUOCUT4DzIuA=";
            };
          });
        };
      })
    ])
  ];
}
