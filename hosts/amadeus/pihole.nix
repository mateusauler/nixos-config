{ config, nixpkgs-unstable, ... }:

{
  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    # Only allow connecting to the web interface from netbird
    interfaces.wt0.allowedTCPPorts = [
      80
      443
    ];
  };

  containers.pihole = {
    autoStart = true;

    # Currently not available in stable
    nixpkgs = nixpkgs-unstable;

    config =
      { ... }:
      {
        environment.enableAllTerminfo = true;

        services.pihole-ftl = {
          enable = true;
          openFirewallWebserver = true;
          useDnsmasqConfig = true;

          queryLogDeleter = {
            enable = true;
            age = 30;
          };

          settings = {
            dns.upstreams = [
              "9.9.9.9"
              "149.112.112.112"
              "2620:fe::fe"
              "2620:fe::9"
            ];
            # misc.readOnly = false;
            webserver.interface = {
              boxed = false;
              theme = "default-darker";
            };
          };
        };

        services.pihole-web = {
          enable = true;
          ports = [
            "80r"
            "443s"
          ];
        };

        networking.hostName = config.networking.hostName;
        networking.firewall.allowedUDPPorts = [ 53 ];

        system.stateVersion = "25.05";
      };
  };
}
