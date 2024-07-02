{ config, lib, ... }:

let
  cfg = config.modules.neovim;
in
lib.mkIf cfg.enable {
  programs.nixvim.plugins.trim = {
    settings.ft_blocklist = [
      "diff"
      "gitsendemail"
      "patch"
    ];
  };
}
