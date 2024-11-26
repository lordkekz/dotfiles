{
  vmName,
  vmId,
}: {
  config,
  pkgs,
  ...
}: {
  systemd.network.enable = true;
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-${vmName}";
      mac = "02:00:00:00:00:${vmId}";
    }
  ];

  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = "10.0.0.${vmId}/24";
      Gateway = "10.0.0.1";
    };
  };

  # SSH Plumbing
  services.openssh = {
    enable = true;
    banner = ''
      SCP-173 is right behind you!
    '';
  };
  users.users.mario = {
    isNormalUser = true;
    password = "hihiaha";
    extraGroups = ["wheel"];
  };
  users.groups.users = {};

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.package = pkgs.lix;

  # Globally enable git.
  programs.git.enable = true;
  programs.git.lfs.enable = true;

  # Add some basic utilities to path.
  # These are basically free because they're on the host anyways.
  environment.systemPackages = with pkgs; [
    fastfetch
    du-dust
    duf
    nix-tree
    bat
    nushell
    tealdeer
    yazi
    neovim
    btop
  ];

  # It is highly recommended to share the host's nix-store
  # with the VMs to prevent building huge images.
  microvm.shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "9p";
      # virtiofs should also be possible but needs extra config for zfs
      # https://astro.github.io/microvm.nix/shares.html
    }
  ];
}
