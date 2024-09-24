{
  description = "Nico Swan user configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin } @inputs:
    let  
      #inherit (self) outputs;
      #inherit (nixpkgs) lib;

      #mkSystem = import lib/mksystem.nix {
      #   inherit nixpkgs outputs inputs lib home-manager nix-darwin; 
      #};
    in
    {
      #mkSystem = mkSystem;
      mkSystem = import lib/mksystem.nix;

      HomeManagerModules = {
          zsh-shell = import modules/home-manager/programs/zsh-shell;
      };
    };
}
