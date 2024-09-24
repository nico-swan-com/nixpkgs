{ configVars, ...}
:{

  imports = [
    ../../../modules/bcb/system/host-updater.nix
    ../../../modules/bcb/system/nginx
    #../../../modules/kubernetes/k0s.nix
  ];

  services.bcb.nginx ={
   enable = true;
   vhostDirectories = [ "/User/${configVars.username}/.config/bcb/vhosts" ];
  };


  services.bcb.host-updater= {
    enable = true;
    userHome = "/Users/${configVars.username}";
  };  


  # services.k0s = {
  #   enable = true;
  #   version = "v1.30.4-k0s.0";
  #   volume = "/var/lib/k0s";
  #   dataStorageLocation = "~/.config/k0s/volumes";
  #   port = "6443";
  #   podman = false;
  #   configDir = "~/.config/k0s/etc";
  # };

}