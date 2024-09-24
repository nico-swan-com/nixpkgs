{
  description = "NixOS module for Gefyra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux"; # Adjust this to your system architecture
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosModules.gefyra = { config, ... }: {
        options.gefyra = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Gefyra";
          };
        };

        config = mkIf config.gefyra.enable {
          environment.systemPackages = with pkgs; [
            (pkgs.fetchzip {
              url = "https://github.com/gefyrahq/gefyra/releases/download/2.2.2/gefyra-2.2.2-darwin-universal.zip";
              sha256 = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; # Replace with the correct hash
            })
          ];
        };
      };

      # Home Manager module
      homeManagerConfigurations = {
        myHomeManager = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          modules = [
            {
              home.packages = with pkgs; [
                (pkgs.fetchzip {
                  url = "https://github.com/gefyrahq/gefyra/releases/download/2.2.2/gefyra-2.2.2-darwin-universal.zip";
                  sha256 = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; # Replace with the correct hash
                })
              ];
            }
          ];
        };
      };
    };
}
