{ lib, pkgs, ... }:

{
  options.shell-aliases = lib.mkOption { type = with lib.types; attrsOf str; };

  config.shell-aliases = {
    cleanup-after-bad-patch = "${pkgs.fd}/bin/fd '\.(orig|rej)$' -X rm";
    wget = "wget --hsts-file $XDG_CACHE_HOME/wget-hsts";
  };
}
