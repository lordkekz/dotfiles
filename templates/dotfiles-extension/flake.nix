{
  description = "A flake which extends my dotfiles and re-exports overwritten `homeConfiguration`s and `nixosConfiguration`s";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles-base = {
      url = "github:lordkekz/dotfiles";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
      };
    };
  };
  outputs = inputs @ {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    dotfiles-base,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

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
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: (dotfiles-base.packages.${system}
      // {
        # Override/add packages in here.
      }));

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    legacyPackages = forAllSystems (system: (dotfiles-base.legacyPackages.${system}
      // {
        homeConfigurations =
          dotfiles-base.legacyPackages.${system}.homeConfigurations
          // {
            # Override/add home-manager configurations in here.
          };
        # Override/add legacyPackages in here.
      }));

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays =
      dotfiles-base.overlays
      // {
        # Override/add overlays in here.
      };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules =
      dotfiles-base.nixosModules
      // {
        # Override/add nixos modules in here.
      };

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules =
      dotfiles-base.homeManagerModules
      // {
        # Override/add home-manager modules in here.
      };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#<hostname>'
    nixosConfigurations =
      dotfiles-base.nixosConfigurations
      // {
        # Override/add NixOS configurations in here.
      };
  };
}
