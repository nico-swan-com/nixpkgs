{ pkgs, ... }:
{
  imports = [
    # Set the default container manager
    ./podman.nix

    # Added colima to run VM on make
    #./colima.nix
  ];
  # Useful development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
  ];


}
