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
    maximized = false;
  };
in
lib.mkIf (cfg.enable && cfg.neovide.enable) {
  home.packages = [ pkgs.neovide ];

  modules.neovim.opts.guifont = lib.mkDefault (
    with osConfig.defaultFonts.mono; "${name}:h${toString size}"
  );

  programs.nixvim.globals.neovide_transparency = lib.mkDefault 0.8;

  xdg.configFile."neovide/config.toml".source = conf;
}
