{ pkgs, ... }:
{

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    docker.enable = true;
  };

  # Useful otherdevelopment tools
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
