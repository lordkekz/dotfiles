{
  description = "A cookie jar full of flakes.";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
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
          pkgs = nixpkgs.legacyPackages.${system};
        in
          (import ./pkgs pkgs)
          // {hm = home-manager.packages.${system}.default;}
          // import ./lib/sketchyHomeConfigurationsForNixShow.nix {
            inherit pkgs system;

            # Standalone home-manager configuration entrypoint
            # Available through 'home-manager --flake .#your-username@your-hostname'
            homeConfigs = (import ./home) {
              inherit pkgs home-manager nixpkgs inputs outputs;
            };
          }
      );

    apps =
      forAllSystems
      (
        system: let
          pkgs = nixpkgs.legacyPackages.${system};

          homeConfigs = (import ./home) {
            inherit pkgs home-manager nixpkgs inputs outputs;
          };
          hostConfigs = import ./hosts {
            inherit nixpkgs inputs outputs;
            pkgs = nixpkgs.legacyPackages.${system};
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
    nixosConfigurations = forAllSystems (system: import ./hosts nixpkgs nixpkgs.legacyPackages.${system} inputs outputs);
  };
}
