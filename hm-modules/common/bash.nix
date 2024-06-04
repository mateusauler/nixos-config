{ config, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = config.shell-aliases // config.programs.fish.shellAbbrs // { ".." = "cd .."; };
    historyControl = [
      "ignorespace"
      "ignoredups"
      "erasedups"
    ];
  };
  home.sessionVariables.HISTFILE = "${config.xdg.stateHome}/bash/history";
}
