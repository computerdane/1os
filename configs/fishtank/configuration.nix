{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    desktop.enable = true;
    dynamic-dns.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
    protonvpn.enable = true;
  };

  # Disable libinput's button "bounce" debounce for the mouse so rapid
  # clicks (drag/butterfly clicking) aren't filtered as switch chatter.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Razer DeathAdder V4 Pro]
    MatchName=Razer DeathAdder V4 Pro
    ModelBouncingKeys=1

    [Glorious Model D 2 PRO - 4K/8KHz Edition]
    MatchName=Glorious Model D 2 PRO - 4K/8KHz Edition
    ModelBouncingKeys=1
  '';

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
    "20-vmic" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "Virtual Mic";
            "capture.props" = {
              "node.name" = "vmic-in";
              "audio.position" = "[ MONO ]";
              "node.target" =
                "alsa_input.usb-HP__Inc_HyperX_Cloud_III_Wireless_0000000000000000-00.mono-fallback";
            };
            "playback.props" = {
              "node.name" = "vmic-out";
              "media.class" = "Audio/Source";
              "audio.position" = "[ MONO ]";
            };
          };
        }
      ];
    };
  };
}
