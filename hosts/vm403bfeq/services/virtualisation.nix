{pkgs,...}:{
  virtualisation.docker.enable = false;
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers.backend = "podman";
  };

   # Useful tools
  environment.systemPackages = with pkgs; [
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
  ];

  # virtualisation.oci-containers.containers = {
  #   helloworld = {
  #     image = "testcontainers/helloworld:latest";
  #     ports = ["8080:8080" "8081:8081"];
  #   };
  # };
}

