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
    stress-ng
  ];

  services.ollama = {
    enable = false;
    package = pkgs.unstable.ollama;
    acceleration = "rocm";
    host = "[::]";
    loadModels = [
      "deepseek-r1:14b"
      "qwen3-coder:30b"
    ];
    environmentVariables = {
      OLLAMA_GPU_MEMORY_FRACTION = "0.9";
    };
  };

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
