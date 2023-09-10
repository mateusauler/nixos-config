{ config, lib, ... }:

{
  gua =	"git remote | sed '/^blacklist/{d}' | xargs -L1 git push --all";
  gsu	= "git remote | sed '/^blacklist/{d}' | xargs -I {} git branch -u {}/(git branch --show-current) (git branch --show-current)";
  cleanup-after-bad-patch = "rm *.{rej, orig}";
  wget = "wget --hsts-file $XDG_CACHE_HOME/wget-hsts";
  sqlite3	= "sqlite3 -init $XDG_CONFIG_HOME/sqlite3/sqliterc";

  l   = "ls";
  la  = "ls -a";
  ll  = "ls -lFb";
  lla = "ll -a";

  rm = "rm -I";
  cp = "cp -r";
} // lib.attrsets.optionalAttrs
  config.programs.eza.enable
  { ls = "eza --group-directories-first --icons"; }
