{ config, lib, nix-colors, pkgs, ... }@args:

let
  cfg = config.modules.bash;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  programs.bash = {
    enable = true;
    shellAliases = config.shell-aliases
                // config.programs.fish.shellAbbrs
                // { ".." = "cd .."; };
    historyControl = [ "ignorespace" "ignoredups" "erasedups" ];
    initExtra = "${lib.getExe pkgs.bash} ${nix-colors-lib.shellThemeFromScheme { scheme = config.colorScheme; }}";
  };
  home.sessionVariables.HISTFILE = "${config.xdg.stateHome}/bash/history";
}
