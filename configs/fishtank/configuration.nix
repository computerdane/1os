{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    desktop.enable = true;
    dynamic-dns.enable = true;
    extra-users.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
    protonvpn.enable = true;
  };

  specialisation.amdvlk.configuration = {
    oneos.gpu-amd.amdvlk = true;
  };

  environment.systemPackages = with pkgs; [
    godot_4
    heroic
    kdePackages.kdenlive
    mumble
    stress-ng
  ];

  services.pipewire.extraConfig.pipewire = {
    "10-loopback" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "Loopback to Headset";
            "capture.props" = {
              "node.name" = "loopback_to_headset";
              "media.class" = "Audio/Sink";
              "audio.position" = "[ FL FR ]";
            };
            "playback.props" = {
              "node.name" = "playback.loopback_to_headset";
              "audio.position" = "[ FL FR ]";
              "target.object" =
                "alsa_output.usb-HP__Inc_HyperX_Cloud_III_Wireless_0000000000000000-00.analog-stereo";
            };
          };
        }
      ];
    };
  };

  # Needed for easyeffects
  programs.dconf.enable = true;
}
