{ config, nixpkgs-unstable, ... }:

{
  networking.firewall = {
    # DNS
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];

    # DHCP
    interfaces.eno0.allowedUDPPorts = [ 67 ];

    # Only allow connecting to the web interface from netbird
    interfaces.wt0.allowedTCPPorts = [
      80
      443
    ];
  };

  containers.pihole = {
    autoStart = true;

    # For DHCP
    additionalCapabilities = [ "CAP_NET_ADMIN" ];

    # Currently not available in stable
    nixpkgs = nixpkgs-unstable;

    config =
      { ... }:
      {
        environment.enableAllTerminfo = true;

        networking.hostName = config.networking.hostName;
        networking.firewall.enable = false;

        services.pihole-web = {
          enable = true;
          ports = [
            "80r"
            "443s"
          ];
        };

        services.pihole-ftl = {
          enable = true;

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

            dhcp = {
              active = true;
              router = "192.168.0.1";
              start = "192.168.2.1";
              end = "192.168.253.250";
              netmask = "255.255.0.0";
              leaseTime = "1d";
              ipv6 = true;
              rapidCommit = true;
              multiDNS = true;
            };

            misc.dnsmasq_lines = [
              # This DHCP server is the only one on the network
              "dhcp-authoritative"
            ];

            # misc.readOnly = false;

            webserver.interface = {
              boxed = false;
              theme = "default-darker";
            };
          };

          lists = [
            {
              url = "https://raw.githubusercontent.com/anudeepND/whitelist/refs/heads/master/domains/whitelist.txt";
              type = "allow";
            }

            { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"; }
            { url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"; }
            { url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/fake.txt"; }
            { url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"; }
            { url = "https://big.oisd.nl"; }

            # https://firebog.net/

            # Suspicious
            { url = "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"; }
            { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"; }
            { url = "https://v.firebog.net/hosts/static/w3kbl.txt"; }

            # Ads
            { url = "https://adaway.org/hosts.txt"; }
            { url = "https://v.firebog.net/hosts/AdguardDNS.txt"; }
            { url = "https://v.firebog.net/hosts/Admiral.txt"; }
            { url = "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"; }
            { url = "https://v.firebog.net/hosts/Easylist.txt"; }
            {
              url = "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext";
            }
            { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"; }
            { url = "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"; }

            # Tracking
            { url = "https://v.firebog.net/hosts/Easyprivacy.txt"; }
            { url = "https://v.firebog.net/hosts/Prigent-Ads.txt"; }
            { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"; }
            { url = "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"; }
            { url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"; }

            # Malicious
            {
              url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt";
            }
            { url = "https://v.firebog.net/hosts/Prigent-Crypto.txt"; }
            { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"; }
            {
              url = "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt";
            }
            { url = "https://phishing.army/download/phishing_army_blocklist_extended.txt"; }
            { url = "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"; }
            { url = "https://v.firebog.net/hosts/RPiList-Malware.txt"; }
            { url = "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"; }
            {
              url = "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts";
            }
            { url = "https://urlhaus.abuse.ch/downloads/hostfile/"; }
            { url = "https://lists.cyberhost.uk/malware.txt"; }
          ];
        };

        system.stateVersion = "25.05";
      };
  };
}
