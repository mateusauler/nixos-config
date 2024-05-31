{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.modules.neovim;

  conf = (pkgs.formats.toml { }).generate "neovide-config.toml" {
    fork = true;
    idle = false;
    maximized = false; # FIXME: Not working
  };
in
lib.mkIf (cfg.enable && cfg.neovide.enable) {
  home.packages = [ pkgs.neovide ];

  programs.nixvim = {
    opts.guifont = lib.mkDefault (with osConfig.defaultFonts.mono; "${name}:h${toString size}");
    globals.neovide_transparency = lib.mkDefault 0.8;
  };

  xdg.configFile."neovide/config.toml".source = conf;
}
