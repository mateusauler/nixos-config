{ config, ... }:

let
  dots-path = with config.dots; if clone then path else nix-uri;
  nom-suffix = "--verbose --log-format internal-json 2>&1 | nom --json";
in
{
  programs.fish.shellAbbrs = rec {
    # Nix

    nrb = "nixos-rebuild --flake ${dots-path} --show-trace build ${nom-suffix}";
    nrs = "sudo true && sudo nixos-rebuild --flake ${dots-path} switch ${nom-suffix}";
    nrt = "sudo true && sudo nixos-rebuild --flake ${dots-path} test ${nom-suffix}";
    nrbt = "sudo true && sudo nixos-rebuild --flake ${dots-path} boot ${nom-suffix}";

    nfc = "nix flake check --show-trace ${nom-suffix}";

    # Utilities & common commands

    c = "cd";
    cp = "cp -r";
    rm = "rm -I";

    l = "ls";
    la = "ls -a";
    ll = "ls -l";
    lla = "ls -la";

    mn = "udisksctl mount -b";
    um = "udisksctl unmount -b";

    img = "nsxiv -a";
    im = img;

    md = "mkdir -p";

    hexdump = "hexdump -C";

    py = "python3";

    "!!" = {
      position = "anywhere";
      function = "last_history_item";
    };
  };
}
