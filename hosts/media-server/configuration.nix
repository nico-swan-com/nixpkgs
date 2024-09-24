{ configVars, ... }:

{
  imports =
    [
      # Core configuration
      ../common/core
      ../common/core/sops.nix
      ../common/core/locale.nix
      ../common/users
      ./system

      #Security
      ../common/optional/services/security/fail2ban.nix

      # Service 
      ./services
    ];

  system.stateVersion = configVars.stateVersion;
}
