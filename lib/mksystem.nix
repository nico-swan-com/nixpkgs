# This function creates a NixOS or NixDarwin system based 
{ nixpkgs, inputs, outputs, lib, home-manager, nix-darwin, ... }:
name:
{ system 
, username 
, fullname
, email
, locale
, timezone
, darwin ? false
, homeManagerModules? [ ]
, extraModules ? [ ]
, overlays? [ ]
}:

let
  inherit (nixpkgs) lib;
  pkgs = nixpkgs;

  # The config files for this system.
  configuration = if darwin then ../nix-darwin/configuration.nix else ../nixos/configuration.nix ;
  homeManager = ../home-manager/default.nix;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManagerModules = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
  userHomeDirectory = if darwin then "/Users/${username}" else "/home/${username}";

  cfg = {
    username = username;
    fullname = fullname; 
    email = email; 
    locale = locale;
    timezone = timezone;
  };
  specialArgs = { inherit nixpkgs inputs cfg; };

in
systemFunc rec {
  inherit specialArgs;
  inherit system;

  modules = [
    (if !darwin then { 
      i18n.defaultLocale = lib.mkDefault locale;
      time.timeZone = lib.mkDefault timezone;
     } else { })

    {
      nixpkgs.overlays = overlays;
      nixpkgs.config.allowUnfree = true;
      nix = {
        settings = {
          experimental-features = "nix-command flakes";
          auto-optimise-store = true;
        };
      };
    }

    {
      # Users
      users.users."${username}" = {
        name = "${username}";
        home = userHomeDirectory;
        description = "${fullname}";
      };
    }

    configuration

    homeManagerModules.home-manager {
     home-manager = {
       useGlobalPkgs = true;
       extraSpecialArgs = specialArgs;
       users.${username} = import homeManager;
     };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = specialArgs;
    }
  ] ++ extraModules;
}

