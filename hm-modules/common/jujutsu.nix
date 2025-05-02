{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.jj;
  git = config.programs.git;
in
{
  options.modules.jj = with lib; {
    enable = pkgs.lib.mkTrueEnableOption "Jujutsu";
    gpgKey = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    lazyjj = pkgs.lib.mkTrueEnableOption "Lazyjj";
  };

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = git.userName;
          email = git.userEmail;
        };
        revset-aliases."immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
        ui = {
          pager = ":builtin";
          diff-editor = ":builtin";
          default-command = "log";
          show-cryptographic-signatures = true;
        };
        signing = lib.mkIf (cfg.gpgKey != null) {
          behavior = "own";
          backend = "gpg";
          key = cfg.gpgKey;
        };
      };
    };
    home.packages = lib.optional cfg.lazyjj pkgs.lazyjj;
    modules.jj.gpgKey = lib.mkDefault config.modules.git.gpgKey;
  };
}
