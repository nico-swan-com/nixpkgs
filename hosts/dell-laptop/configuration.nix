{ configVars, ... }:
{
  imports =
    [
      # Core configuration
      ../common/core
      ../common/core/sops.nix
      ../common/core/locale.nix
      ../common/users

      # Include the results of the hardware scan.
      ./system

      # Services 
      ./services

      # Programs and Applications
      ./packages

    ];

  system.stateVersion = configVars.stateVersion;

}
