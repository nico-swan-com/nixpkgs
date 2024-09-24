{ lib, ... }:
let
  IPAddress = "192.168.1.100";
in
{

  networking = {
    hostName = "dell-laptop";
    domain = "nicoswan.com";

    # Enable networking
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    useDHCP = lib.mkDefault false;
    # interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
    interfaces.wlp2s0.useDHCP = lib.mkDefault false;
    interfaces.wlp2s0.ipv4 = {
      addresses = [{ address = IPAddress; prefixLength = 24; }];
    };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };

}
