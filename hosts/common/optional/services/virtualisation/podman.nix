{ pkgs, ... }:
{
  # Enable common container config files in /etc/containers
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = false;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Useful otherdevelopment tools
  environment.systemPackages = with pkgs; [
    podman-tui # status of containers in the terminal
    podman-desktop
    podman-compose # start group of containers for dev
  ];
}
