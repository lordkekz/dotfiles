# All my terminal-specific user configuration.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  mode,
  ...
}: {
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [neofetch];

  programs.tmux = {
    enable = true;
    #package = pkgs.tmux;
    mouse = true;
    shell = "${pkgs.nushell}/bin/nu";
    clock24 = true;
    newSession = true;
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      pain-control
      power-theme
      sidebar
    ];
  };

  programs.nushell = {
    enable = true;
    envFile.text = "";
    configFile.text = ''
      $env.config.show_banner = false;
      printf $'(ansi cyan_bold)Thou shalt worm thyself, now!(ansi reset)'
    '';
    loginFile.text = "";
  };

  programs.bat = {
    enable = true;
    config.style = "full";
    extraPackages = with pkgs.bat-extras; [batman];
  };

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
