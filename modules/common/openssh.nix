{
  config,
  lib,
  pkgs,
  private-config,
  ...
}@args:

let
  inherit (lib) mkDefault;
  cfg = config.modules.openssh;

  public-machine-paths = lib.foldl (
    acc: hostname: acc // { ${hostname} = ../../hosts/${hostname}; }
  ) { } (lib.readDirNames ../../hosts);

  private-machine-paths = lib.mapAttrs (_: host: host.config.hostBaseDir) (
    private-config.systems (args // { inherit (pkgs) system; })
  );

  machine-paths = public-machine-paths // private-machine-paths;

  knownHosts = lib.mapAttrs (_: machine-path: {
    publicKeyFile = machine-path + /ssh_host_ed25519_key.pub;
  }) machine-paths;
in
{
  options.modules.openssh.enable = lib.mkEnableOption "openssh";

  config = lib.mkIf cfg.enable {
    services = {
      openssh = {
        inherit knownHosts;
        enable = true;
        startWhenNeeded = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
      sshguard = {
        enable = true;
        attack_threshold = 15;
      };
    };
    security.rtkit.enable = mkDefault true;
  };
}
