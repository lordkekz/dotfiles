{
  description = "A cookie jar full of flakes.";

  inputs = {
    ## PURE-NIX UTILITIES ##

    # Flake utils for stripping some boilerplate
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

    # Haumea for directory-defined attrset loading
    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs";

    # My personal data which is *not* technically secret but I don't want to show in this repo.
    personal-data.url = "github:lordkekz/personal-data";
    personal-data.inputs.haumea.follows = "haumea";
    personal-data.inputs.systems.follows = "systems";
    personal-data.inputs.nixpkgs.follows = "nixpkgs";

    # The list of supported systems.
    systems.url = "github:nix-systems/default-linux";

    ## PACKAGES, CONFIGURATION AND APPLICATIONS ##

    # Hardware configs for known systems.
    hardware.url = "github:nixos/nixos-hardware";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nixpkgs
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    # A nixpkgs downstream which only contains the lib
    #nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    # NixVim distro for neovim
    nixvim.url = "github:nix-community/nixvim/main";
    #nixvim.url = "github:lordkekz/nixvim/main";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # Doesn't work: nixvim.inputs.pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    # see: https://github.com/msteen/nix-flake-override

    # Mirror of VSCode marketplace and Open VSX registry.
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS-WSL
    NixOS-WSL.url = "github:nix-community/NixOS-WSL";
    NixOS-WSL.inputs.nixpkgs.follows = "nixpkgs";

    # Plasma manager
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # Use sops-nix for secret management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
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
    lib = hl.load {
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

    homeManagerModules = hl.load {
      src = ./modules/home-manager;
      inputs = {
        inherit (nixpkgs) lib;
        flake = self;
      };
      # Load it without passing inputs, to preserve the functional nature of the modules
      loader = hl.loaders.verbatim;
    };

    nixosModules = hl.load {
      src = ./modules/nixos;
      inputs = {
        inherit (nixpkgs) lib;
        flake = self;
      };
      # Load it without passing inputs, to preserve the functional nature of the modules
      loader = hl.loaders.verbatim;
    };

    homeProfiles = lib.loadProfiles "home";
    nixosProfiles = lib.loadProfiles "nixos";
    hardwareProfiles = lib.loadProfiles "hardware";

    templates.dotfiles-extension = {
      path = ./templates/dotfiles-extension;
      description = "A template to dynamically extend my dotfiles without forking them.";
    };
  in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      # CHANNEL DEFINITIONS
      # Channels are automatically generated from nixpkgs inputs
      # e.g the inputs which contain `legacyPackages` attribute are used.
      channelsConfig.allowUnfree = true;

      # HOST DEFINITIONS
      hostDefaults = {
        modules = attrValues nixosModules;
        specialArgs = {
          inherit inputs outputs nixosProfiles hardwareProfiles;
          inherit (inputs) personal-data;
        };
        channelName = "nixpkgs";
        system = "x86_64-linux";
      };

      # declare hosts in flake.nix (hosts are defined by hostname, arch and profiles)
      hosts.kekswork2312.modules = [nixosProfiles.kde hardwareProfiles.framework-laptop-2022];
      hosts.kekstop2304.modules = [nixosProfiles.hypr hardwareProfiles.desktop-2015];
      hosts.nasman.modules = [nixosProfiles.headless hardwareProfiles.server-ryzen-2024];
      hosts.vortex.modules = [nixosProfiles.headless hardwareProfiles.vps-2023];
      hosts.nixos-wsl2.modules = [nixosProfiles.wsl];

      # PER-SYSTEM OUTPUTS
      outputsBuilder = channels: {
        # generate homeConfigurations from homeProfiles
        legacyPackages.homeConfigurations = mapAttrs (homeProfileName: homeProfile:
          home-manager.lib.homeManagerConfiguration {
            pkgs = channels.nixpkgs;
            extraSpecialArgs = {
              inherit inputs outputs homeProfiles;
              inherit (inputs) personal-data;
              pkgs-stable = channels.nixpkgs-stable;
              pkgs-unstable = channels.nixpkgs-unstable;
              system = channels.nixpkgs.system;
            };
            modules = [homeProfile] ++ (attrValues homeManagerModules);
          })
        homeProfiles;

        # Output channels for easier debugging in nix repl
        inherit channels;

        formatter = channels.nixpkgs.alejandra;
      };

      # SYSTEMLESS OUTPUTS

      # export homeProfiles and nixosProfiles but not hardwareProfiles
      profiles.nixos = nixosProfiles;
      profiles.home = homeProfiles;

      # export generic homeManagerModules and nixosModules (e.g. patched versions to be upstreamed)
      inherit homeManagerModules nixosModules;

      # export lib, templates, etc.
      inherit lib templates;
    };
}
