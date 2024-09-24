{ pkgs, ... }:
{
  imports = [
    ./docker.nix
    ./podman.nix
  ];
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;

  # Useful otherdevelopment tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
  ];
}
