# My private git configuration.
args @ {
  inputs,
  outputs,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
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
  # General Git
  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
    aliases = {
      lg = ''log --pretty=format:"%C(cyan)@%an%Creset%C(dim)[%Creset%C(green bold)%G?%Creset%C(dim)]%Creset%C(auto) %h%d %s" --graph'';
      lga = ''lg --all'';
      ec = ''commit --allow-empty'';
      amend = ''commit --amend'';
      root = ''rev-parse --show-toplevel'';
    };
    attributes = [
      # global .gitattributes
    ];
    inherit (personal-data.data.home.git) userName userEmail;
    signing = {
      inherit (personal-data.data.home.git.signing) key;
      signByDefault = true;
      gpgPath = "${wsl-gpg-wrapper}/bin/wsl-gpg-wrapper";
    };
  };

  programs.gpg = {
    enable = true;
  };

  # GitHub and stuff
  programs.gh = {
    enable = true;
    # TODO maybe configure aliases
    settings = {};
    # TODO maybe add some extensions
    extensions = [];
  };
  programs.gh-dash = {
    enable = true;
    settings = {
      # TODO maybe configure PR sections etc.
    };
  };
}
