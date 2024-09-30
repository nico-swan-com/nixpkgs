{
  description = "Example flake to apply nicoswan nixpkgs";

  inputs = {

    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";

    # Add nicoswan packages and modules 
    nicoswan = {
      url = "github:nico-swan-com/nixpkgs/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MacOS packages
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User packages
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , nicoswan
    , ...
    } @inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      mkSystem = nicoswan.mkSystem {
        inherit nixpkgs outputs inputs lib nix-darwin home-manager;
      };
    in
    {
      darwinConfigurations.darwin = mkSystem "darwin" {
        system = "aarch64-darwin";
        username = "nicoswan";
        fullname = "Nico Swan";
        email = "hi@nicoswan.com";
        locale = "en_ZA.UTF-8";
        timezone = "Africa/Johannesburg";
        darwin = true;
        extraModules = [ ./configuration.nix ];
        extraHMModules = [ ./home.nix ];
      };
    };

}
