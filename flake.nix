{
  description = "dotfiles managed with Home Manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nix-darwin, ... }:
    let
      username = "am";
      stateVersion = "25.05";

      mkPkgs = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkHome = {
        system,
        homeDirectory,
        module,
      }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = {
            inherit inputs username homeDirectory;
          };
          modules = [
            module
            {
              home = {
                inherit username homeDirectory stateVersion;
              };
            }
          ];
        };

      mkDarwin = {
        system,
        homeDirectory,
      }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs username homeDirectory stateVersion;
          };
          modules = [
            ./nix/darwin/common.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs username homeDirectory;
              };
              home-manager.users.${username} = { ... }: {
                imports = [ ./nix/home/darwin.nix ];
                home = {
                  inherit username homeDirectory stateVersion;
                };
              };
            }
          ];
        };
    in {
      homeConfigurations = {
        am-linux = mkHome {
          system = "x86_64-linux";
          homeDirectory = "/home/am";
          module = ./nix/home/linux.nix;
        };

        am-darwin = mkHome {
          system = "aarch64-darwin";
          homeDirectory = "/Users/am";
          module = ./nix/home/darwin.nix;
        };

        am-darwin-intel = mkHome {
          system = "x86_64-darwin";
          homeDirectory = "/Users/am";
          module = ./nix/home/darwin.nix;
        };
      };

      darwinConfigurations = {
        am-darwin = mkDarwin {
          system = "aarch64-darwin";
          homeDirectory = "/Users/am";
        };

        am-darwin-intel = mkDarwin {
          system = "x86_64-darwin";
          homeDirectory = "/Users/am";
        };
      };
    };
}
