{ config, pkgs, ... }:
let
  # When using easyCerts=true the IP Address must resolve to the master on creation.
  # So use simply 127.0.0.1 in that case. Otherwise you will have errors like this https://github.com/NixOS/nixpkgs/issues/59364
  kubeMasterIP = "102.135.163.95";
  kubeMasterHostname = "api.kubernetes";
  kubeMasterAPIServerPort = 6443;

  keyFile = "${config.sops.secrets."cygnus-labs/kubernetes/keyFile".path}";
  certFile = "${config.sops.secrets."cygnus-labs/kubernetes/certFile".path}";
  caFile = "${config.sops.secrets."cygnus-labs/kubernetes/caFile".path}";

in
{
  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes
    openiscsi
    nfs-utils
    cifs-utils
    cryptsetup
    lvm2
  ];

  # Fixes for longhorn
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    "d /data/openebs/local 0755 root root"
  ];
  virtualisation.docker.logDriver = "json-file";

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
  };

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
      allowPrivileged = true;
    };

    # Addons
    addons.dns.enable = true;
    kubelet.extraOpts = ''
      --fail-swap-on=false
    '';

    kubeconfig = {
      caFile = caFile;
      certFile = certFile;
      keyFile = keyFile;
    };
    # Addons
    # addons.dns = {
    #   enable = true; # use coredns
    #   clusterDomain = "cluster.private";
    # };

    # # needed if you use swap
    # kubelet.extraOpts = ''
    #   --fail-swap-on=false
    #   --resolv-conf=/run/systemd/resolve/resolve.conf
    # '';
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

}
