{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.bat;
in
{
  options.modules.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      # Set bat as the default man reader
      # Also fix the incorrect display of ansi escape sequences (https://github.com/sharkdp/bat/issues/2668#issuecomment-1807916150)
      MANPAGER = "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'";
      MANROFFOPT = "-c";
    };

    programs.bat.enable = true;
  };
}
