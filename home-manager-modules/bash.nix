{ custom, config, lib, pkgs, ... }:

let cfg = config.modules.bash;
in {
  programs.bash = {
    enable = true;
    shellAliases = (import ./shell-aliases.nix { inherit config; })
                // (import ./fish/abbreviations.nix { inherit custom; })
                // { ".." = "cd .."; };
    historyControl = [ "ignorespace" "ignoredups" "erasedups" ];
  };
}
