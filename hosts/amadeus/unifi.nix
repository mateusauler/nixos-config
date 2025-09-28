{ lib, ... }:

let
  firewall = {
    allowedTCPPorts = [
      8080 # UAP to inform controller
      8880 # HTTP portal redirect, if guest portal is enabled
      8843 # HTTPS portal redirect, ditto
      6789 # UniFi mobile speed test
      8443 # Web GUI
    ];
    allowedUDPPorts = [
      3478 # STUN
      10001 # Device discovery
    ];
  };
in
{
  networking = { inherit firewall; };

  modules.proxy.services.unifi = {
    port = 8443;
    protocol = "https";
  };

  containers.unifi = {
    autoStart = true;

    bindMounts."/var/lib/unifi" = {
      hostPath = "/tank/containers/unifi";
      isReadOnly = false;
    };

    config =
      { ... }:
      {
        services.unifi.enable = true;

        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "unifi-controller"
            "mongodb"
          ];

        networking = { inherit firewall; };

        system.stateVersion = "25.05";
      };
  };
}
