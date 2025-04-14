{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.neovim;

  conf = (pkgs.formats.toml { }).generate "neovide-config.toml" {
    fork = true;
    idle = false;
    maximized = false;
  };
in
lib.mkIf (cfg.enable && cfg.neovide.enable) {
  home.packages = [ pkgs.neovide ];

  programs.nixvim = {
    opts.guifont = lib.mkDefault (
      with config.stylix.fonts; "${monospace.name}:h${toString sizes.terminal}"
    );
    globals.neovide_opacity = lib.mkDefault config.stylix.opacity.terminal;
  };

  xdg.configFile."neovide/config.toml".source = conf;
}
