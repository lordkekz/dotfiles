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

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-unstable,
    ...
  }: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux" # 64-bit ARM with Linux
      "x86_64-linux" # 64-bit x86 with Linux
      # I don't use any 32-bit systems or darwin systems.
    ];

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument.
    # forallSystems :: fn ("SystemName" -> {...}) -> { SystemName = {...}; ...}
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # System-agnostic args
    args = {inherit inputs outputs;};

    # System-specific args
    mkArgs = system:
      args
      // {
        inherit system;
        pkgs-stable = import nixpkgs-stable {inherit system;};
        pkgs-unstable = import nixpkgs-unstable {inherit system;};
        pkgs = import nixpkgs {inherit system;};
      };

    # Importing stuff
    importPkgs = system: import ./pkgs (mkArgs system);
    importHome = system: import ./home (mkArgs system);
    hosts = import ./hosts args;
  in rec {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems importPkgs;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    legacyPackages = forAllSystems importHome;

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays args;

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = (import ./modules/nixos args) // hosts.nixosModules;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager args;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#<hostname>'
    inherit (hosts) nixosConfigurations nixosConfigurationParams;

    # Templates for related flakes
    templates.dotfiles-extension = {
      path = ./templates/dotfiles-extension;
      description = "A template to dynamically extend my dotfiles without forking them.";
    };

    # Custom library functions
    lib = import ./lib;
  };
}
