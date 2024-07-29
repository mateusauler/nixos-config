{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.chromium;
in
{
  options.modules.chromium.enable = lib.mkEnableOption "Chromium";
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # Ublock Origin
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC-Browser
        {
          # Chromium Web Store
          id = "ocaahdebbfolfmndjeplogmgcagdmblk";
          updateUrl = "https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/master/updates.xml";
        }
      ];
    };
  };
}
