{ lib, ... }:

{
  options.shell-aliases = lib.mkOption { type = with lib.types; attrsOf str; };

  config = {
    shell-aliases = {
      gua = /* bash */ "git remote | sed '/^blacklist/{d}' | xargs -L1 git push --all";
      gsu = /* bash */ "git remote | sed '/^blacklist/{d}' | xargs -I {} git branch -u {}/(git branch --show-current) (git branch --show-current)";
      cleanup-after-bad-patch = "rm *.{rej, orig}";
      wget = "wget --hsts-file $XDG_CACHE_HOME/wget-hsts";
      sqlite3 = "sqlite3 -init $XDG_CONFIG_HOME/sqlite3/sqliterc";

      la = "ls -a";
      ll = "ls -lb";
      lla = "ll -a";

      rm = "rm -I";
      cp = "cp -r";
    };
  };
}
