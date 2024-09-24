{ pkgs, configVars, ... }:

{
  imports = [
    # Setup users 
    # See the var/default.nix for the default configured users
    ../../home/users/${configVars.username}
    ./modules/bcb/user

    # All user manditory configuration and packages
    ../../home/common/core

    # Optional packages and configiration for this host
    ../../home/common/optional/sops.nix
    ../../home/common/optional/desktop/fonts.nix
    ../../home/common/optional/development/google-cloud-sdk.nix
    ../../home/common/optional/terminal/nnn.nix

    # BCB Services
    ./services/home-manager/bcb
    ./services/home-manager/colima.nix
  ];

  home.username = configVars.username;
  home.homeDirectory = "/Users/${configVars.username}";
  home.stateVersion = configVars.stateVersion;

}
