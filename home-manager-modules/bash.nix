{ config, nix-colors, pkgs, ... }@args:

let
  cfg = config.modules.bash;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  programs.bash = {
    enable = true;
    shellAliases = (import ./shell-aliases.nix args)
                // (import ./fish/abbreviations.nix args)
                // { ".." = "cd .."; };
    historyControl = [ "ignorespace" "ignoredups" "erasedups" ];
    initExtra = "sh ${nix-colors-lib.shellThemeFromScheme { scheme = config.colorScheme; }}";
  };
  home.sessionVariables.HISTFILE = "${config.xdg.stateHome}/bash/history";
}
