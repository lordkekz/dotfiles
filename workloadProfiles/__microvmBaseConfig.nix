{
  personal-data,
  vmName,
  vmId,
  user,
  group,
  unitsAfterPersist,
  pathsToChown,
  fsType ? "ext4",
}: {
  lib,
  config,
  pkgs,
  ...
}: {
  microvm.mem = 3072; # This can't be exactly 2GiB because QEMU hangs otherwise
  microvm.vcpu = 4;

  systemd.network.enable = true;
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-${vmName}-a";
      mac = "02:00:00:00:00:${vmId}";
    }
    {
      type = "tap";
      id = "vm-${vmName}-b";
      mac = "02:00:00:00:01:${vmId}";
    }
  ];

  systemd.network.links = {
    "10-rename-lan-a" = {
      matchConfig.MACAddress = "02:00:00:00:00:${vmId}";
      linkConfig.Name = "vm-${vmName}-a";
    };
    "10-rename-lan-b" = {
      matchConfig.MACAddress = "02:00:00:00:01:${vmId}";
      linkConfig.Name = "vm-${vmName}-b";
    };
  };

  systemd.network.networks = {
    "20-lan-a" = {
      matchConfig.MACAddress = "02:00:00:00:00:${vmId}";
      networkConfig = {
        Address = "10.0.0.${vmId}/24";
        Gateway = "10.0.0.1";
      };
    };
    "20-lan-b" = {
      matchConfig.MACAddress = "02:00:00:00:01:${vmId}";
      networkConfig = {
        Address = "100.80.64.${vmId}/24";
        Gateway = "100.80.64.1";
      };
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
    inherit (personal-data.data.lab.microvm) hashedPassword;
    extraGroups = ["wheel" "systemd-journal"];
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
  #
  # Note that some shares are on virtiofs and some are on 9p.
  # I did some benchmarks as of 2024-12-10:
  # - nasman2404 on host    gets 3070MiB/s and 800k IOPS when reading,
  #                                              similar when writing
  # - microvm with 9p       gets  360MiB/s and  90k IOPS when reading,
  #                               300MiB/s and  75k IOPS when writing
  # - microvm with virtiofs gets 1500MiB/s and 380k IOPS when reading,
  #                         only   77MiB/s and  20k IOPS when writing (!)
  # - microvm with volume   gets 1500MiB/s and 360k IOPS when reading,
  #                              2850MiB/s and 750k IOPS when writing
  # Thus, I'm using virtiofs for the read-only /nix shares but volumes
  # for the read-write persistent directories.
  microvm.shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "microvm-${vmName}-ro-store";
      proto = "virtiofs";
    }
  ];

  microvm.volumes = [
    {
      mountPoint = "/persist";
      image = "/dev/zvol/artemis/microvm-${vmName}";
      autoCreate = false;
      inherit fsType;
    }
  ];

  # This is probably only needed on first boot to set the xargs due to 9p mount mode "mapped"
  # Better to chown them at each start of the VM so the files can be touched from the host without worry
  systemd.services.init-permissions = {
    enableStrictShellChecks = true;
    script =
      lib.concatMapStrings (path: ''
        echo "chowning '${path}' for ${user}:${group}"
        if chown -Rc "${user}:${group}" '${path}'; then
          echo "chown done"
        else
          echo "chown failed"
        fi
      '')
      pathsToChown;
    # oneshot services count as "activating" until script exits, afterwards "inactive (dead)".
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "no";
    wantedBy = ["multi-user.target"] ++ unitsAfterPersist;
    before = ["multi-user.target"] ++ unitsAfterPersist;
    wants = ["fs.target"];
    after = ["fs.target"];
  };
}
