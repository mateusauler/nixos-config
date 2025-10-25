{
  lib,
  inputs,
  nixpkgs-channel,
  pkgs,
  private-config,
  ...
}:

{
  nixpkgs.overlays = lib.flatten [
    private-config.overlays
    (final: prev: {
      nsxiv = pkgs.symlinkJoin {
        inherit (prev.nsxiv) name;
        paths = [ prev.nsxiv ];
        postInstall = ''
          sed -i -E 's/Exec\s*=\s*nsxiv\s*(.*)$/Exec=nsxiv -a \1/' $out/share/applications/nsxiv.desktop
        '';
      };
      niri = pkgs.symlinkJoin {
        inherit (prev.niri) name cargoBuildNoDefaultFeatures cargoBuildFeatures;
        paths = [ prev.niri ];
        postBuild = ''
          install -Dm755 "${./niri-session}" "$out/bin/niri-session"
        '';
      };
      android-tools =
        let
          script = pkgs.writeShellScript "adb" ''
            HOME=''${XDG_DATA_HOME:-$HOME/.local/share}/android exec ${prev.android-tools}/bin/adb "$@"
          '';
        in
        pkgs.symlinkJoin {
          inherit (prev.android-tools) name;
          paths = [ prev.android-tools ];
          postBuild = ''
            install -Dm755 "${script}" "$out/bin/adb"
          '';
        };
      wget =
        let
          script = pkgs.writeShellScript "wget" ''
            exec ${lib.getExe prev.wget} --hsts-file ''${XDG_CACHE_HOME:-$HOME/.cache}/wget-hsts "$@"
          '';
        in
        pkgs.symlinkJoin {
          inherit (prev.wget) name;
          paths = [ prev.wget ];
          postBuild = ''
            install -Dm755 "${script}" "$out/bin/wget"
          '';
        };
    })
    (lib.optional (nixpkgs-channel == "unstable") (
      final: prev: {
        inherit (import inputs.nixpkgs-pr-454590 { inherit (prev.stdenv.hostPlatform) system; }) copyq;
      }
    ))
  ];
}
