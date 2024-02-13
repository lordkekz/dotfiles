# My private git configuration.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  # extraSpecialArgs:
  system,
  username,
  ...
}: let
  windows-gpg-path = "/mnt/c/Program Files (x86)/GnuPG/bin/gpg.exe";

  wsl-gpg-wrapper = pkgs.writeShellApplication {
    # A wrapper which runs either gpg2 or, if on WSL2, the Windows host's gpg.
    name = "wsl-gpg-wrapper";
    runtimeInputs = [pkgs.gnupg];
    text = ''
      if grep -qi "WSL2" /proc/version; then
          # Running inside WSL2
      	"${windows-gpg-path}" "$@"
      else
          # Not running inside WSL2
          gpg2 "$@"
      fi
    '';
  };
in {
  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
    };
    attributes = [
      # global .gitattributes
    ];
    userName = "lordkekz";
    userEmail = "lordkekz@lkekz.de";
    signing = {
      key = "340729DA7E86CF0F";
      signByDefault = true;
      gpgPath = "${wsl-gpg-wrapper}/bin/wsl-gpg-wrapper";
    };
  };

  programs.gpg = {
    enable = true;
  };
}
