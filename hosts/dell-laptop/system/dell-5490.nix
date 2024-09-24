{ lib, ... }:
{
  # Hardware for DELL 5490
  # Essential Firmware
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  # Cooling Management
  services.thermald.enable = lib.mkDefault true;
  # Enable fwupd
  services.fwupd.enable = lib.mkDefault true;
}
