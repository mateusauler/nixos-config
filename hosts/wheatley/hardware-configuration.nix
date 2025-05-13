{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/deeb0b25-f23a-435e-8cb8-ec7d05bf2dca";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  fileSystems."/tmp".fsType = "tmpfs";

  boot.initrd.luks.devices."luks-c058bec9-bb26-440c-805c-75808b15c20d".device = "/dev/disk/by-uuid/c058bec9-bb26-440c-805c-75808b15c20d";

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
      options = [
        "nofail"
        "noatime"
      ];
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
