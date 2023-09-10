{ config, ... }@args:

let cfg = config.modules.bash;
in {
  programs.bash = {
    enable = true;
    shellAliases = (import ./shell-aliases.nix args)
                // (import ./fish/abbreviations.nix args)
                // { ".." = "cd .."; };
    historyControl = [ "ignorespace" "ignoredups" "erasedups" ];
  };
}
