{ lib, ... }:
{
  imports = [
    ../../common/core/nix-settings.nix
    ./hardware-configuration.nix
    ./boot-loader.nix
    ./xserver.nix
    ./sound.nix
    ./networking.nix
    ./dell-5490.nix
    ./gnome-desktop.nix
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
