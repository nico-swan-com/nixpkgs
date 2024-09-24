{ config, pkgs, ... }:
let
  # When using easyCerts=true the IP Address must resolve to the master on creation.
  # So use simply 127.0.0.1 in that case. Otherwise you will have errors like this https://github.com/NixOS/nixpkgs/issues/59364
  kubeMasterIP = "192.168.1.100";
  kubeMasterHostname = "dell-laptop";
  kubeMasterAPIServerPort = 6443;

in
{
  # resolve master hostname
  networking.extraHosts = ''
    ${kubeMasterIP} ${kubeMasterHostname} api.kubernetes dell-laptop;
  '';

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    k9s
  ];

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # Addons
    addons.dns.enable = true; # use coredns

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  # networking = {
  #   bridges = {
  #     cbr0.interfaces = [ ];
  #   };
  #   interfaces = {
  #     cbr0.ipv4.addresses = [{
  #       address = "10.10.0.1";
  #       prefixLength = 24;
  #     }];
  #   };
  # };
  # networking.nameservers = [ "10.10.0.1" ];
  # virtualisation.podman = {
  #   enable = true;
  #   # extraOptions =
  #   #   ''--iptables=false --ip-masq=false -b cbr0'';
  # };
}
