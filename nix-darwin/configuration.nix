{ pkgs, cfg, ... }:
{
  imports = [
    # Core must have system installations
    ../modules/core-configuration.nix
    ./macos-settings.nix
  ];

  nixpkgs.hostPlatform = mkForce "aarch64-darwin";
  system.stateVersion = 5;

  programs = {
    zsh = {
      enableFzfCompletion = true;
      enableFzfGit = true;
      enableFzfHistory = true;
    };
  };

  # List system packages only for MacOS 
  environment.systemPackages = with pkgs; [
    terminal-notifier # send notification from the terminal
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Nix settings
  nix = {
    settings = {
      # Necessary for using flakes on this system.
      extra-platforms = [ "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      extra-trusted-users = [ "@admin" "@localhost" ];

      # Add needed system-features to the nix daemon
      # Starting with Nix 2.19, this will be automatic
      system-features = [ "apple-virt" ];
    };
    # Linux builder for building packages from source  
    linux-builder.enable = true;
    # Configure nix garbage collection
    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 1;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };
}
