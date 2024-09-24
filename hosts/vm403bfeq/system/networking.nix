{

  # Open ports in the firewall.
  networking.firewall.enable = false;
  # networking.firewall = {
  #   allowedTCPPorts = [ 80 443 22 6443 5432 8888 ];
  # };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.useDHCP = false; # lib.mkDefault true;
  networking.interfaces.ens18.ipv4.addresses = [{
    address = "102.135.163.95";
    prefixLength = 24;
  }];
  networking.defaultGateway = "102.135.163.1";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.hostName = "vm403bfeq"; # Define your hostname.
  networking.domain = "cygnus-labs.com";

  # Enable NAT for containers
  #networking.nat.enable = true;
  #networking.nat.internalInterfaces = ["ve-+"];
  #networking.nat.externalInterface = "ens18";

}
