{
  description = "Nico Swan nixpkgs custom modules collection and tools";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin } @inputs:
    {
      # Wrapper for making sytems
      mkSystem = import ./lib/mkSystem.nix;
      HomeManagerModules = import ./modules/home-manager;
    };
}
