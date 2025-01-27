# Virtualisation config
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
  # Enable Incus Linux containers
  virtualisation.incus = {
    enable = false; # FIXME Incus on NixOS is unsupported using iptables. Set `networking.nftables.enable = true;`
    # Start when socket opened instead of at boot.
    socketActivation = true;
  };

  # Enable podman containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    extraPackages = [pkgs.podman-compose];
  };

  # Enable Waydroid to run Android apps
  virtualisation.waydroid.enable = true;
  systemd.services.waydroid-container.wantedBy = lib.mkForce [];

  # Enable virt-manager for QUEMU/KVM based VMs
  virtualisation.libvirtd = {
    enable = false;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          })
          .fd
        ];
      };
    };
  };
  programs.virt-manager.enable = false;
}
