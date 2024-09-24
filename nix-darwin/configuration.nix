{cfg, ...}:
{
  imports = [
    # Core must have system installations
    ../modules/core-configuration.nix
    ./macos-settings.nix 
  ];
  services.nix-daemon.enable = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  programs = {
    zsh = {
      enableFzfCompletion = true;
      enableFzfGit = true;
      enableFzfHistory = true;
    };
  };


  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

}
