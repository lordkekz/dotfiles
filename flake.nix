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

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    plasma-manager,
    hardware,
    nix-vscode-extensions,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in rec {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages =
      forAllSystems
      (
        system: let
          pkgs = import nixpkgs {inherit system;};
        in
          (import ./pkgs {inherit pkgs system;})
          // {
            hm = home-manager.packages.${system}.default;
            pm = plasma-manager.packages.${system}.default;
          }
          // (import ./lib/sketchyHomeConfigurationsForNixShow.nix {
            inherit pkgs system;

            # Standalone home-manager configuration entrypoint
            # Available through 'home-manager --flake .#your-username@your-hostname'
            homeConfigs = (import ./home) {
              inherit pkgs home-manager nixpkgs inputs outputs system;
            };
          })
      );

    apps =
      forAllSystems
      (
        system: let
          pkgs = import nixpkgs {inherit system;};

          homeConfigs = (import ./home) {
            inherit inputs outputs pkgs nixpkgs system home-manager;
          };
          hostConfigs = import ./hosts {
            inherit inputs outputs pkgs nixpkgs system hardware;
          };
          myListOfHomeConfigs = import ./lib/listOfHomeConfigs.nix {inherit pkgs homeConfigs;};
          myListOfHostConfigs = import ./lib/listOfHostConfigs.nix {inherit pkgs hostConfigs;};
          script = pkgs.writeShellApplication {
            name = "apply-dotfiles-all";
            runtimeInputs = [pkgs.nushell pkgs.home-manager];
            text = ''
              echo "{
                homeConfigs: ${myListOfHomeConfigs.listNamesNuonEscaped}
                hostConfigs: ${myListOfHostConfigs.listNamesNuonEscaped}
              }" | nu --stdin ${./apply.nu}
            '';
          };
          app = {
            type = "app";
            program = "${script}/bin/apply-dotfiles-all";
          };
        in {default = app;}
      );

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#<hostname>'
    nixosConfigurations = import ./hosts {
      inherit nixpkgs inputs outputs;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };
  };
}
