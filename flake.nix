{
  description = "A cookie jar full of flakes.";

  inputs = {
    # Nixpkgs
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Plasma manager
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # Use sops-nix for secret management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";

    # Hardware configs for known systems.
    hardware.url = "github:nixos/nixos-hardware";

    # Mirror of VSCode marketplace and Open VSX registry.
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    # NixVim distro for neovim
    nixvim.url = "github:nix-community/nixvim/main";
    #nixvim.url = "github:lordkekz/nixvim/main";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # Doesn't work: nixvim.inputs.pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    # see: https://github.com/msteen/nix-flake-override

    # NixOS-WSL
    NixOS-WSL.url = "github:nix-community/NixOS-WSL";
    NixOS-WSL.inputs.nixpkgs.follows = "nixpkgs";

    # A nixpkgs downstream which only contains the lib
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    # Haumea for directory-defined attrset loading
    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs-lib";

    # My personal data which is *not* technically secret but I don't want to show in this repo.
    personal-data.url = "github:lordkekz/personal-data";
    personal-data.inputs.haumea.follows = "haumea";
    personal-data.inputs.systems.follows = "systems";
    personal-data.inputs.nixpkgs.follows = "nixpkgs";

    # The list of supported systems.
    systems.url = "github:nix-systems/default-linux";

    # Flake utils for stripping some boilerplate
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.0";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-unstable,
    systems,
    flake-utils-plus,
    haumea,
    ...
  }: let
    inherit (self) outputs;
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

    homeProfiles = lib.loadProfiles "home" outputs.homeManagerModules;
    nixosProfiles = lib.loadProfiles "nixos" outputs.nixosModules;
    hardwareProfiles = lib.loadProfiles "hardware" outputs.nixosModules;

    templates.dotfiles-extension = {
      path = ./templates/dotfiles-extension;
      description = "A template to dynamically extend my dotfiles without forking them.";
    };
  in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      # Channel definitions.
      # Channels are automatically generated from nixpkgs inputs
      # e.g the inputs which contain `legacyPackages` attribute are used.
      channelsConfig.allowUnfree = true;

      hostDefaults.extraArgs = {
        # TODO anything required here?
      };

      # TODO declare hosts in flake.nix (hosts are defined by hostname, arch and profiles)

      # TODO generate homeConfigurations from homeProfiles

      # export homeProfiles and nixosProfiles but not hardwareProfiles
      inherit homeProfiles nixosProfiles;

      # TODO export generic homeManagerModules and nixosModules (e.g. patched versions to be upstreamed)
      inherit homeManagerModules nixosModules;

      # TODO load & export lib, templates, etc.
      inherit lib templates;

      # TODO define formatter
    };
}
