{
  config,
  lib,
  nixpkgs-channel,
  ...
}:

let
  cfg = config.modules.neovim;
  indent = true;
in
lib.mkIf cfg.enable {
  programs.nixvim.plugins.treesitter =
    {
      nixvimInjections = true;
    }
    // (
      if nixpkgs-channel == "stable" then { inherit indent; } else { settings.indent.enable = indent; }
    );
}
