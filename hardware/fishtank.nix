# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      FCTEMPS=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=/sys/devices/pci0000:00/0000:00:03.1/0000:0e:00.0/0000:0f:00.0/0000:10:00.0/hwmon/hwmon[[:print:]]*/temp1_input /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=/sys/devices/pci0000:00/0000:00:03.1/0000:0e:00.0/0000:0f:00.0/0000:10:00.0/hwmon/hwmon[[:print:]]*/temp1_input
      FCFANS=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/fan7_input+/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/fan4_input /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/fan4_input
      MINTEMP=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=40 /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=40
      MAXTEMP=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=70 /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=70
      MINSTART=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=100 /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=100
      MINSTOP=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=100 /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=100
      MINPWM=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=100 /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=100
      MAXPWM=/sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm7=255 /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]*/pwm4=255
    '';
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  # boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "nct6775" ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.universal-pidff ];

  boot.supportedFilesystems = [ "ntfs" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", ACTION=="add", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="pci", DRIVER=="amdgpu", ATTR{power_dpm_force_performance_level}="manual"
    SUBSYSTEM=="pci", DRIVER=="amdgpu", ATTR{pp_power_profile_mode}="3d_full_screen"
  '';

  hardware.bluetooth.enable = true;

  # hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  # hardware.graphics.enable32Bit = true;
  # systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];

  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      # efiInstallAsRemovable = true;
      devices = [ "nodev" ];
      useOSProber = true;
      configurationLimit = 8;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c2a5816f-af17-4d9f-9b55-3c52100cc342";
    fsType = "ext4";
  };

  fileSystems."/extra" = {
    device = "/dev/disk/by-uuid/75b5816f-193e-4124-a55a-ece13fb2419b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A10A-AD21";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05";
}
