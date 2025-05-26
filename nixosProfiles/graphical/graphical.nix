# Graphical/Desktop system.
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  imports = [nixosProfiles.common];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  programs.dconf.enable = true;

  # Force GTK apps to use portal for file picker
  environment.variables."GTK_USE_PORTAL" = "1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Configure OBS with virtual camera (needs kernel module)
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-backgroundremoval
      input-overlay
    ];
    enableVirtualCamera = true;
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    search = [
      "hepr.me"
      "fritz.box"
      "halosaur-wahoo.ts.net"
    ];
  };
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [""];
    fallbackDns = []; # Refuse non-DoH DNS
    dnsovertls = "true";
  };

  # Configure power events
  services.logind = {
    powerKey = "suspend";
    lidSwitch = "lock";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "lock";

    #killUserProcesses = true; # breaks persistent tmux sessions
  };
}
