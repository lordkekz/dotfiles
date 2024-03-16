# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/base-config.nix
  ];

  boot.kernelParams = [ "copytoram" ];
  boot.tmp.useTmpfs = true;
  boot.readOnlyNixStore = false;

  networking.hostName = "nixos-minimal";

  environment.systemPackages = with pkgs; [
    # Cool stuff
    pkgs.fastfetch
    pkgs.nushell
    pkgs.bat
    pkgs.btop
    pkgs.ookla-speedtest
    pkgs.geekbench
  ];

  # Enable SSH for headless access
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
  users.users.nixos = {
    password = "5cLFL4D3r4F6"; # This is really, really not safe at all! But it's easy, so...
    isNormalUser = true;
    group = "nixos";
  };
  users.groups.nixos = {};
}
