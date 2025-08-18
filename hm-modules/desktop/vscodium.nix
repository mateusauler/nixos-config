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

  config = lib.mkIf (cfg.enable && config.home.username != "root") {
    xdg.configFile."VSCodium/product.json".text = ''
      {
        "extensionsGallery": {
          "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
          "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
          "itemUrl": "https://marketplace.visualstudio.com/items"
        }
      }
    '';

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium.fhs;

      profiles.default = {
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

        extensions = with pkgs.vscode-extensions; [
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
        ];
      };
    };
  };
}
