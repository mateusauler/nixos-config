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
      inherit (lib) strings lists;
      file = builtins.readFile (package + "/share/applications/${desktopFile}.desktop");
      lines = strings.splitString "\n" file;
      mimeLine = lists.findFirst (s: strings.hasPrefix "MimeType" s) "" lines;
      mimeTypesCombined = builtins.substring 9 (-1) mimeLine;
      mimeTypesDirty = strings.split ";" mimeTypesCombined;
      mimeTypes = lists.flatten mimeTypesDirty;
    in
    lists.remove "" mimeTypes;
in
{
  imports = [ ./compliance.nix ];

  options.modules.xdg.enable = lib.mkEnableOption "xdg";

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
            "inode/directory" = "pcmanfm.desktop";
            "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
          }
          // (lib.foldl (acc: e: acc // (genAssociations e)) { } (
            [
              {
                types =
                  [
                    "text/html"
                    "application/xhtml+xml"
                  ]
                  ++ (map (t: "x-scheme-handler/${t}") [
                    "http"
                    "https"
                    "ftp"
                    "chrome"
                  ])
                  ++ (map (t: "application/x-extension-${t}") [
                    "htm"
                    "html"
                    "shtml"
                    "xhtml"
                    "xht"
                  ]);
                handlers = [ "browser" ];
              }
            ]
            ++ (map
              (
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
                }
              )
              (
                with pkgs;
                [
                  {
                    pkg = nsxiv;
                    desktopFile = "nsxiv";
                  }
                  {
                    pkg = mpv-unwrapped;
                    desktopFile = "mpv";
                    extraDesktopFiles = "vlc";
                  }
                  {
                    pkg = neovim;
                    desktopFile = "nvim";
                    extraDesktopFiles = "codium";
                  }
                ]
              )
            )
          ));
      };
    };

    home.packages = [ pkgs.xdg-utils ];
  };
}
