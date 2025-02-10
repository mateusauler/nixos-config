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

    home.activation.disableChromiumAutoVolumeGain =
      let
        jq = "${pkgs.jq}/bin/jq";
        sponge = "${pkgs.moreutils}/bin/sponge";

        configDir = config.xdg.configHome;
        localState = "${configDir}/chromium/Local State";

        optionValue = "enable-webrtc-allow-input-volume-adjustment@2";
        optionPath = ".browser.enabled_labs_experiments";
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] # bash
        ''
          mkdir -p "${configDir}/chromium"

          if [[ ! -f "${localState}" ]]; then
            echo "{}" > "${localState}"
          fi

          if ! ${jq} -e '${optionPath}[] | select(. == "${optionValue}")' "${localState}" > /dev/null 2>&1;
          then
            ${jq} -c '${optionPath} += ["${optionValue}"]' "${localState}" \
              | ${sponge} "${localState}"
          fi
        '';
  };
}
