{
  description = "A cookie jar full of flakes.";

  inputs = {
    ## PURE-NIX UTILITIES ##

    # Devenv (for this repo's devShells)
    devenv.url = "github:cachix/devenv";

    # Disko for declarative partitioning
    disko.url = "github:nix-community/disko?ref=v1.9.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Flake utils for stripping some boilerplate
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus?ref=v1.5.1";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

    # Haumea for directory-defined attrset loading
    haumea.url = "github:nix-community/haumea?ref=v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs";

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";

    # My personal data which is *not* technically secret but I don't want to show in this repo.
    personal-data.url = "github:lordkekz/personal-data";
    #personal-data.url = "/home/hpreiser/git/personal-data";
    personal-data.inputs.haumea.follows = "haumea";
    personal-data.inputs.systems.follows = "systems";
    personal-data.inputs.nixpkgs.follows = "nixpkgs";

    # The list of supported systems.
    systems.url = "github:nix-systems/default-linux";

    ## PACKAGES, CONFIGURATION AND APPLICATIONS ##

    agenix.url = "github:ryantm/agenix";
    agenix.inputs = {
      systems.follows = "systems";
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    # Anyrun is a modern, wayland-native runner written in Rust.
    anyrun.url = "github:lordkekz/anyrun?ref=add-nix-overlay";
    #anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware configs for known systems.
    hardware.url = "github:nixos/nixos-hardware";

    # Home manager
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Lix (correctness-focused fork of Nix)
    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    # microvm.nix
    #microvm.url = "github:astro/microvm.nix?ref=main";
    microvm.url = "github:lordkekz/microvm.nix?ref=initialize-shares-permissions"; # FIXME update after merge
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    # Tmux status bar configured in Rust
    #muxbar.url = "github:Dlurak/muxbar";
    muxbar.url = "github:lordkekz/muxbar"; # FIXME Update once PR gets merged
    muxbar.inputs.devenv.follows = "devenv";
    muxbar.inputs.nixpkgs.follows = "nixpkgs";
    muxbar.inputs.systems.follows = "systems";

    # Nixpkgs
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    # A nixpkgs downstream which only contains the lib
    #nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    # nix-index allows searching for binary names; nix-index-database contains a prebuilt db for nix-index.
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # NixVim distro for neovim
    nixvim.url = "github:nix-community/nixvim/main";
    #nixvim.url = "github:lordkekz/nixvim/main";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # Doesn't work: nixvim.inputs.pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    # see: https://github.com/msteen/nix-flake-override

    # Mirror of VSCode marketplace and Open VSX registry.
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions?ref=master";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    # Yazi plugins
    #nix-yazi-plugins.url = "github:lordkekz/nix-yazi-plugins?ref=main";
    nix-yazi-plugins.url = "/home/hpreiser/git/nix-yazi-plugins";
    nix-yazi-plugins.inputs.nixpkgs.follows = "nixpkgs";

    # Yazi flake
    yazi.url = "github:sxyazi/yazi?ref=v0.4.1";
    #yazi.inputs.nixpkgs.follows = "nixpkgs-unstable"; # FIXME there's an infinite recursion as of 2024-12-15

    # Generate images etc. from NixOS configs
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    nixos-generators.inputs.nixlib.follows = "nixpkgs";

    # Simple NixOS mailserver
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
    nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-mailserver.inputs.nixpkgs-24_11.follows = "nixpkgs-stable";

    # NixOS-WSL
    NixOS-WSL.url = "github:nix-community/NixOS-WSL";
    NixOS-WSL.inputs.nixpkgs.follows = "nixpkgs";

    # Plasma manager
    plasma-manager.url = "github:pjones/plasma-manager?ref=trunk";
    #plasma-manager.url = "/home/hpreiser/git/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # Stylix helps theme applications using base16
    #stylix.url = "/home/hpreiser/git/stylix";
    stylix.url = "github:lordkekz/stylix?ref=fix-plasma-activation"; # FIXME switch back to upstream once merged
    #stylix.url = "github:danth/stylix?ref=master";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";

    # Hyprland, a wayland tiling compositor
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.39.1";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.inputs.systems.follows = "systems";
    hyprlock.url = "github:hyprwm/hyprlock?ref=main"; #FIXME update with the next release
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";
    hyprlock.inputs.systems.follows = "systems";
    hypridle.url = "github:hyprwm/hypridle?ref=v0.1.2";
    hypridle.inputs.nixpkgs.follows = "nixpkgs";
    hypridle.inputs.systems.follows = "systems";
    hyprpaper.url = "github:hyprwm/hyprpaper?ref=v0.6.0";
    hyprpaper.inputs.nixpkgs.follows = "nixpkgs";
    #hyprpaper.inputs.systems.follows = "systems";
    hyprpicker.url = "github:hyprwm/hyprpicker?ref=v0.2.0";
    hyprpicker.inputs.nixpkgs.follows = "nixpkgs";
    #hyprpicker.inputs.systems.follows = "systems";
    hyprland-contrib.url = "github:hyprwm/contrib?ref=v0.1";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";
    #hyprland-contrib.inputs.systems.follows = "systems";

    # The phinger-cursor theme, but packaged as a SVG Hyprcursor theme
    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";
    hyprcursor-phinger.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Walker, a Wayland-native runner
    walker.url = "github:abenz1267/walker";

    # Worms.tex contains my custom texmf stuff
    worms-tex = {
      url = "github:lordkekz/worms.tex";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-utils-plus,
    haumea,
    home-manager,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-unstable,
    self,
    systems,
    ...
  }: let
    inherit (self) outputs;
    inherit (nixpkgs.lib) attrValues mapAttrs;

    hl = haumea.lib;
    lib =
      nixpkgs.lib
      // {
        my = hl.load {
          src = ./lib;
          inputs = {
            inherit (nixpkgs) lib;
            flake = self;
          };
          # Load it but require explicit inputs line in each file
          loader = hl.loaders.default;
          # Make the default.nix's attrs directly children of lib
          transformer = hl.transformers.liftDefault;
        };
      };

    homeManagerModules = hl.load {
      src = ./modules/home-manager;
      inputs = {
        inherit lib;
        flake = self;
      };
      # Load it without passing inputs, to preserve the functional nature of the modules
      loader = hl.loaders.verbatim;
    };

    nixosModules = hl.load {
      src = ./modules/nixos;
      inputs = {
        inherit lib;
        flake = self;
      };
      # Load it without passing inputs, to preserve the functional nature of the modules
      loader = hl.loaders.verbatim;
    };

    homeProfiles = lib.my.loadProfiles "home";
    nixosProfiles = lib.my.loadProfiles "nixos";
    hardwareProfiles = lib.my.loadProfiles "hardware";
    workloadProfiles = lib.my.loadProfiles.loadModulesOfProfiles "workload";
    getHomeConfig = system: name: outputs.legacyPackages.${system}.homeConfigurations.${name};
    mkSessions = system: {
      config.multi-hm.sessions = {
        kde = {
          homeConfiguration = getHomeConfig system "kde";
          launchCommand = "startplasma-wayland";
          displayName = "Plasma 6 (mutli-hm)";
        };
        #hypr = {
        #  homeConfiguration = getHomeConfig system "hypr";
        #  launchCommand = "Hyprland";
        #  displayName = "Hyprland (multi-hm)";
        #};
      };
      config.services.displayManager.defaultSession = lib.mkForce "kde";
    };

    # A set containing the paths of assets in ./assets directory
    assets = hl.load {
      src = ./assets;
      loader = [(hl.matchers.always hl.loaders.path)];
    };
  in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      # CHANNEL DEFINITIONS
      # Channels are automatically generated from nixpkgs inputs
      # e.g the inputs which contain `legacyPackages` attribute are used.
      channelsConfig.allowUnfree = true;
      sharedOverlays = map (i: i.overlays.default) (with inputs; [
        yazi
        nix-yazi-plugins
        hyprland
        hyprlock
        hypridle
        hyprpaper
        hyprpicker
        hyprland-contrib
        anyrun
        agenix
        agenix-rekey
      ]);

      # HOST DEFINITIONS
      hostDefaults = {
        modules =
          (attrValues nixosModules)
          ++ (with inputs; [
            nixos-generators.nixosModules.all-formats
            lix-module.nixosModules.default
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
          ]);
        specialArgs = {
          inherit inputs outputs assets nixosProfiles hardwareProfiles workloadProfiles;
          inherit (inputs) personal-data;
          system = "x86_64-linux"; # FIXME for other architectures
        };
        channelName = "nixpkgs";
        system = "x86_64-linux";
      };

      # declare hosts in flake.nix (hosts are defined by hostname, arch and profiles)
      hosts = with nixosProfiles;
      with hardwareProfiles; {
        live.modules = [
          live-installer
          (lib.my.mkNixosModuleForHomeProfile (getHomeConfig "x86_64-linux" "terminal"))
        ];

        nasman2404.modules = [
          homelab
          ryzen-server-2404
          (lib.my.mkNixosModuleForHomeProfile (getHomeConfig "x86_64-linux" "terminal"))
        ];

        kekswork2404.modules = [
          personal
          graphical
          framework-laptop-2404
          # Adds entries for graphical sessions which first activate a home configuration
          (mkSessions "x86_64-linux")
          # Fallback so I get a decent tty experience without starting graphical session
          (lib.my.mkNixosModuleForHomeProfile (getHomeConfig "x86_64-linux" "terminal"))
        ];

        keksjumbo2410.modules = [
          personal
          graphical
          framework-laptop-2410
          # Adds entries for graphical sessions which first activate a home configuration
          (mkSessions "x86_64-linux")
          # Fallback so I get a decent tty experience without starting graphical session
          (lib.my.mkNixosModuleForHomeProfile (getHomeConfig "x86_64-linux" "terminal"))
        ];

        vortex.modules = [
          homelab
          vortex
          (lib.my.mkNixosModuleForHomeProfile (getHomeConfig "x86_64-linux" "terminal"))
        ];
      };

      # PER-SYSTEM OUTPUTS
      outputsBuilder = channels: let
        system = channels.nixpkgs.system;
        pkgs = channels.nixpkgs;
        pkgs-stable = channels.nixpkgs-stable;
        pkgs-unstable = channels.nixpkgs-unstable;
        flake = self;
      in {
        # generate homeConfigurations from homeProfiles
        legacyPackages.homeConfigurations = mapAttrs (homeProfileName: homeProfile:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit flake inputs outputs assets system pkgs-stable pkgs-unstable homeProfiles;
              inherit (inputs) personal-data;
              inherit (inputs) stylix-image;
            };
            modules = [homeProfile] ++ (attrValues homeManagerModules);
          })
        homeProfiles;

        packages = hl.load {
          src = ./pkgs;
          inputs = {
            inherit flake inputs outputs assets system pkgs pkgs-stable pkgs-unstable;
          };
          # Load it but require explicit inputs line in each file
          loader = hl.loaders.default;
          # Make the default.nix's attrs directly children of lib
          transformer = hl.transformers.liftDefault;
        };

        # Dev shells
        devShells.default = inputs.devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [./devenv.nix];
        };

        # Output channels for easier debugging in nix repl
        inherit channels;

        formatter = pkgs.alejandra;
      };

      # SYSTEMLESS OUTPUTS

      # Expose the necessary information in your flake so agenix-rekey
      # knows where it has too look for secrets and paths.
      #
      # Make sure that the pkgs passed here comes from the same nixpkgs version as
      # the pkgs used on your hosts in `nixosConfigurations`, otherwise the rekeyed
      # derivations will not be found!
      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = self;
        nodes = {
          inherit (self.nixosConfigurations) kekswork2404 keksjumbo2410 nasman2404 vortex;
        };
        # Example for colmena:
        # inherit ((colmena.lib.makeHive self.colmena).introspect (x: x)) nodes;
      };

      # export homeProfiles and nixosProfiles but not hardwareProfiles
      profiles.nixos = nixosProfiles;
      profiles.home = homeProfiles;
      profiles.workload = workloadProfiles;

      # export generic homeManagerModules and nixosModules (e.g. patched versions to be upstreamed)
      inherit homeManagerModules nixosModules;

      # export lib, templates, etc.
      inherit lib assets;
    };
}
