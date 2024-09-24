{ pkgs, config, configVars, ... }:
{
  imports = [
    ./macos-settings.nix
    ./nix-settings.nix
  ];

  # Set /etc/zshrc
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Users
  users.users."${configVars.username}" = {
    name = configVars.username;
    home = "/Users/${configVars.username}";
  };

  # Locale
  time.timeZone = configVars.timezone;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

}
