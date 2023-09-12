{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.nsxiv;
  xresources = "${config.xdg.configHome}/nsxiv/Xresources";
  load-xresources = "${pkgs.xorg.xrdb}/bin/xrdb ${xresources}";
in {
  options.modules.nsxiv.enable = lib.mkEnableOption "nsxiv";

  config = lib.mkIf cfg.enable {
    modules.hyprland.extraAutostart = { nsxiv-load-config = load-xresources; };
	  home = {
	    packages = with pkgs; [
	      nsxiv
	      xorg.xrdb
	    ];
      file.${xresources} = {
        enable = true;
        text = with config.colorScheme.colors; ''
          *.foreground: #${base05}
          *.background: #${base00}
        '';
        onChange = load-xresources;
      };
    };
  };
}
