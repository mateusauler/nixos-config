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
  options.modules.jj = {
    enable = pkgs.lib.mkTrueEnableOption "Jujutsu";
    gpgKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
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

    programs.fish.shellAbbrs = rec {
      j = "jj";

      ja = "jj abandon";
      jbd = "jj bookmark delete";
      jbf = "jj bookmark forget";
      jb = "jj bookmark";
      jbl = "jj bookmark list";
      jbm = "jj bookmark move --allow-backwards";
      jbmt = "${jbm} --from 'trunk()::@' --to $(jj log -r '::@ ~ empty()' -n 1 -T 'change_id' --no-graph)";
      jbs = "jj bookmark set";
      jc = "jj commit";
      jde = "jj diffedit";
      jdi = "jj diff";
      jd = "jj desc";
      je = "jj edit";
      jf = "jj git fetch";
      jg = "jj git";
      jl = "jj log";
      jlp = "jj log -p";
      jn = "jj new";
      jnt = "jj new 'trunk()'";
      jo = "jj op";
      jol = "jj op log";
      jor = "jj op restore";
      jpc = "jj git push --change @";
      jp = "jj git push";
      jpn = "jj git push --allow-new";
      jpt = "jj git push --revisions 'trunk()'";
      jptr = "jj git push --tracked";
      jre = "jj resolve";
      jr = "jj rebase";
      jrl = "jj resolve -l";
      jrt = "jj rebase --destination 'trunk()'";
      jsh = "jj show";
      js = "jj status";
      jsp = "jj split";
      jsq = "jj squash";
      ju = "jj undo";

      cj = "cd $(jj root 2> /dev/null)";

      lj = lib.mkIf cfg.lazyjj "lazyjj";
    };
  };
}
