{ lib, ... }:
{
  # Open ports in the firewall.
  networking.firewall = {
   allowedTCPPorts = [ 80 443 22 ];
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.eth0.ipv4.addresses = [{
    address = "192.168.1.223";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.hostName = "media"; # Define your hostname.
  networking.domain = "nicoswan.com";
}
