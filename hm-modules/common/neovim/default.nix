{ config, lib, osConfig, pkgs, ... }:

let
  cfg = config.modules.neovim;
  colors = pkgs.writeText "colors.vim" (import ./colors.nix config.colorScheme);
in
{
  options.modules.neovim = {
    enable = lib.mkEnableOption "neovim";
    neovide.enable = lib.mkEnableOption "neovide";
  };

  imports = [
    ./plugins
  ];

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.neovide.enable pkgs.neovide;

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;
      extraConfig = ''
        source ${colors}
        ${builtins.readFile ./config.vim}
      '';
      extraLuaConfig = with osConfig.defaultFonts.mono; ''
        ${lib.optionalString cfg.neovide.enable "vim.o.guifont = \"${name}:h${toString size}\""}
        ${builtins.readFile ./config.lua}
      '';
    };

    # Re-source the config on running nvim instances
    xdg.configFile."nvim/init.lua".onChange = /* bash */ ''
      XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      for server in $XDG_RUNTIME_DIR/nvim.*; do
        $DRY_RUN_CMD ${lib.getExe pkgs.neovim} --server $server --remote-send ':source ${config.xdg.configHome}/nvim/init.lua<CR>' &
      done
    '';
  };
}
