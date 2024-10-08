{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.eza;
in
{
  options.modules.eza.enable = pkgs.lib.mkTrueEnableOption "eza";
  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      git = true;
      icons = true;
      extraOptions = [
        "-b"
        "--group-directories-first"
      ];
    };

    programs.fish.shellAbbrs = rec {
      lt = "ls --tree";
      llt = "${lt} -l";
      lat = "${lt} -a";
      llat = "${lt} -la";
    };
  };
}
