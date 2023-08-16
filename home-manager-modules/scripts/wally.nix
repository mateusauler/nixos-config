{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.wally;
in {
  options.modules.wally = {
    enable = lib.mkEnableOption "wally";
    package = lib.mkOption { default = pkgs.wally-cli; };
    executableName = lib.mkOption { default = "wally-cli"; };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
    let
      wally = pkgs.writeShellScriptBin "wll" ''
        if [ $# -ge 1 ]; then
          ${cfg.package}/bin/${cfg.executableName} "$@" 2> /dev/null
          sleep 1
          rm "$@"
        fi
      '';
    in
    [ wally ];
  };
}