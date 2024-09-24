{ pkgs, ... }:
{
  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    k0sctl
  ];
}
