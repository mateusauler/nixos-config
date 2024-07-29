{ config, lib, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases =
      config.shell-aliases
      // (lib.filterAttrs (_: builtins.isString) config.programs.fish.shellAbbrs)
      // {
        ".." = "cd ..";
      };
    historyControl = [
      "ignorespace"
      "ignoredups"
      "erasedups"
    ];
  };
  home.sessionVariables.HISTFILE = "${config.xdg.stateHome}/bash/history";
}
