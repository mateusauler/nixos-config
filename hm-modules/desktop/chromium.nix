{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.chromium;

  ensureExperimentPresent =
    optionValue:
    let
      jq = "${pkgs.jq}/bin/jq";
      sponge = "${pkgs.moreutils}/bin/sponge";

      configDir = config.xdg.configHome;
      localState = "${configDir}/chromium/Local State";

      optionPath = ".browser.enabled_labs_experiments";
    in
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

    home.activation.chromiumExperiments = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatMapStringsSep "\n" ensureExperimentPresent [
        "enable-webrtc-allow-input-volume-adjustment@2" # Disable auto volume gain
        "extension-mime-request-handling@2" # https://github.com/NeverDecaf/chromium-web-store?tab=readme-ov-file#read-this-first
      ]
    );

    home.file.keepassxc-native-messaging-host-chromium =
      let
        nmh-path = "${config.xdg.configHome}/chromium/NativeMessagingHosts.hm-backup";
      in
      {
        enable = true;
        target = "${nmh-path}/org.keepassxc.keepassxc_browser.json";
        text = # json
          ''
            {
              "allowed_extensions": [
                "chrome-extension://pdffhmdngciaglkoonimfcmckehcpafo/",
                "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
              ],
              "description": "KeePassXC integration with native messaging support",
              "name": "org.keepassxc.keepassxc_browser",
              "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
              "type": "stdio"
            }
          '';
      };
  };
}
