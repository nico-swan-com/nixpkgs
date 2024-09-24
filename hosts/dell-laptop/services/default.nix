{
  imports = [
    # Core services
    #./hydra.nix  # CI tool 
    #./kubernetes.nix # Container management
    #./nextcloud # Own home Cloud 
  ];

  services.onedrive.enable = true;

}
