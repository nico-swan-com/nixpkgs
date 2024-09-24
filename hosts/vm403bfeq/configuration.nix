{ configVars, ... }:
{
  imports =
    [
      # Core configuration
      ../common/core
      ../common/core/sops.nix
      #../common/secrets
      ../common/core/locale.nix
      ../common/users
      ./system
      ./services

      ./extra-users.nix

    ];

  system.stateVersion = configVars.stateVersion;

  sops = {
    secrets = {
      "users/vmbfeqcy/password".neededForUsers = true;
    };
  };

}
