{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault;
  cfg = config.modules.xdg;

  genAssociations =
    { types, handlers }:
    lib.foldl (acc: t: acc // { "${t}" = (map (v: "${v}.desktop") handlers); }) { } types;

  extractMimeTypes =
    package: desktopFile:
    let
      file = builtins.readFile (package + "/share/applications/${desktopFile}.desktop");
      lines = lib.splitString "\n" file;
      mimeLine = lib.findFirst (s: lib.hasPrefix "MimeType" s) "" lines;
      mimeTypesCombined = builtins.substring 9 (-1) mimeLine;
      mimeTypesDirty = lib.split ";" mimeTypesCombined;
      mimeTypes = lib.flatten mimeTypesDirty;
    in
    lib.remove "" mimeTypes;

  associateDesktopFileAndTypes =
    {
      pkg,
      desktopFile,
      extraDesktopFiles ? [ ],
    }:
    {
      types = extractMimeTypes pkg desktopFile;
      handlers = lib.lists.flatten [
        desktopFile
        extraDesktopFiles
      ];
    };
in
{
  imports = [ ./compliance.nix ];

  options.modules.xdg = {
    enable = lib.mkEnableOption "xdg";
    file-manager = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = mkDefault true;
      userDirs =
        let
          home = config.home.homeDirectory;
        in
        {
          enable = mkDefault true;
          desktop = mkDefault null;
          documents = mkDefault "${home}/docs";
          download = mkDefault "${home}/dl";
          music = mkDefault "${home}/music";
          pictures = mkDefault "${home}/pics";
          videos = mkDefault "${home}/vids";
        };
      configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
      mimeApps = {
        enable = mkDefault true;
        defaultApplications =
          {
            "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
          }
          // (lib.optionalAttrs (cfg.file-manager != null) { "inode/directory" = cfg.file-manager; })
          // (lib.foldl (acc: e: acc // (genAssociations (associateDesktopFileAndTypes e))) { } [
            {
              pkg = pkgs.nsxiv;
              desktopFile = "nsxiv";
            }
            {
              pkg = pkgs.mpv-unwrapped;
              desktopFile = "mpv";
              extraDesktopFiles = "vlc";
            }
            {
              pkg = pkgs.neovim;
              desktopFile = "nvim";
              extraDesktopFiles = "codium";
            }
          ]);
      };
    };

    home.packages = [ pkgs.xdg-utils ];
  };
}
