{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  time.timeZone = mkDefault "America/Sao_Paulo";
  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  console.keyMap = mkDefault "br-abnt";
}
