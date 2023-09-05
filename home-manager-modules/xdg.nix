{ custom, config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.xdg;

  genAssociations = { types, handlers }:
    lib.foldl
      (acc: t:
        acc // {
          "${t}" = (map
            (v: "${v}.desktop")
            handlers
          );
        }
      )
      { }
      types;

  extractMimeTypes = package: desktopFile:
    let
      inherit (lib) strings lists;
      file = builtins.readFile (package + "/share/applications/${desktopFile}.desktop");
      lines = strings.splitString "\n" file;
      mimeLine = lists.findFirst (s: strings.hasPrefix "MimeType" s) "" lines;
      mimeLineSplit = strings.splitString "=" mimeLine;
      mimeTypesCombinedList = lists.remove "MimeType" mimeLineSplit;
      mimeTypesCombined = lists.last mimeTypesCombinedList;
      mimeTypesDirty = strings.split ";" mimeTypesCombined;
      mimeTypes = lists.flatten mimeTypesDirty;
    in
      lists.remove "" mimeTypes;
in {
  options.modules.xdg.enable = lib.mkEnableOption "xdg";

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = mkDefault true;
      userDirs = {
        enable = mkDefault true;
        desktop   = mkDefault null;
        documents = mkDefault "${config.home.homeDirectory}/docs";
        download  = mkDefault "${config.home.homeDirectory}/dl";
        music     = mkDefault "${config.home.homeDirectory}/music";
        pictures  = mkDefault "${config.home.homeDirectory}/pics";
        videos    = mkDefault "${config.home.homeDirectory}/vids";
      };
      mimeApps = {
        enable = mkDefault true;
        defaultApplications = {
          "inode/directory" = "pcmanfm.desktop";
          "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
        } // (
        lib.foldl (acc: e: acc // (genAssociations e))
          { }
          (
            [
              {
                types = [ "text/html" "application/xhtml+xml" ]
                     ++ (map (t: "x-scheme-handler/${t}") [ "http" "https" "ftp" "chrome" ])
                     ++ (map (t: "application/x-extension-${t}") [ "htm" "html" "shtml" "xhtml" "xht" ]);
                handlers = [ "browser" ];
              }
            ] ++ (
              map
                ({ p, d, e ? [ ] }: { types = extractMimeTypes p d; handlers = [ d ] ++ e; })
                (with pkgs; [
                  { p = nsxiv;         d = "nsxiv"; }
                  { p = mpv-unwrapped; d = "mpv";  e = [ "vlc" ]; }
                  { p = neovim;        d = "nvim"; e = [ "codium" ];  }
                ])
            )
          )
        );
      };
    };

    home.packages = with pkgs; [
      xdg-utils
    ];
  };
}
