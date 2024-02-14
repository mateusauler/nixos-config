{ pkgs, ... }:

{
  services.rustdesk-server = {
    openFirewall = true;
    relayIP = "amadeus.auler.dev";
  };
}
