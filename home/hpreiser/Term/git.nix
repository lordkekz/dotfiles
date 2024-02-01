# All my terminal-specific user configuration.
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
}: {
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
    };
  };

  programs.gpg = {
    enable = true;
  };
}
