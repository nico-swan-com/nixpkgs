{ config, pkgs, ... }:
{
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Useful tools
  environment.systemPackages = with pkgs; [
    podman-tui # status of containers in the terminal
    podman-desktop # A graphical tool for developing on containers and Kubernetes
    podman-compose # start group of containers for dev
  ];

}
