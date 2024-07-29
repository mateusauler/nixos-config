{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.vscodium;
in
{
  options.modules.vscodium.enable = lib.mkEnableOption "VSCodium";

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = config.home.username != "root";
      package = pkgs.vscodium;

      userSettings = {
        "editor.fontLigatures" = true;
        "editor.minimap.enabled" = false;
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 500;
        "files.trimTrailingWhitespace" = true;
        "python.languageServer" = "Jedi";
        "redhat.telemetry.enabled" = false;
        "update.showReleaseNotes" = false;
        "yaml.maxItemsComputed" = 50000;
      };

      extensions =
        with pkgs.vscode-extensions;
        [
          mkhl.direnv

          # C/C++
          llvm-vs-code-extensions.vscode-clangd

          # Copilot
          github.copilot
          github.copilot-chat

          # JSON
          zainchen.json

          # Jupyter
          ms-toolsai.jupyter
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.jupyter-keymap
          ms-toolsai.vscode-jupyter-slideshow

          # Nix
          arrterian.nix-env-selector
          jnoortheen.nix-ide

          # Python
          ms-python.python
          ms-python.debugpy
          ms-python.pylint
          ms-python.black-formatter

          # Rust
          rust-lang.rust-analyzer

          # YAML
          redhat.vscode-yaml

        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-openapi";
            publisher = "42Crunch";
            version = "4.27.0";
            hash = "sha256-urXGyHpIDWQ0Bc+8LODC0DcEo6jQ5tA/QptyxCej9yU=";
          }
          {
            name = "openapi-designer";
            publisher = "philosowaffle";
            version = "0.3.0";
            hash = "sha256-qDw5hBlRvM1FXpfdvtF1oBr3kHGWK2NK6hJ9QFOpgBM=";
          }
        ];
    };
  };
}
