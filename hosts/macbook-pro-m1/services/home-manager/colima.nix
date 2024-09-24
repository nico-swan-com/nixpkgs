{ pkgs, configVars, ... }:

{
  imports = [
    ../../modules/home-manager/colima.nix
    ../../modules/home-manager/nginx.nix

  ];

  home.packages = with pkgs; [
    k9s
  ];

  programs.zsh = {
    shellAliases = {
      "kube-colima-dev-context" = "kubectl config use-context colima-development-cluster";
      "kdev" = "kubectl --context colima-development-cluster";

    };
  };

  services.colima = {
    enable = true;
    vms = [
      {
        cpu = 4;
        disk = 10;
        memory = 8;
        arch = "aarch64";
        runtime = "docker";
        hostname = "development-cluster";
        kubernetes ={
          enabled = true;
          k3sArgs = ["--no-deploy=traefik"]; 
          kubernetesDisable=["teafik"];
        };
        rosetta = false;
        network.address = true;
        launchd.enable = true;
      }
    ];
  };
  

  # services.colima = {
  #   enable = true;
  #   vms = [
  #     {
  #       cpu = 1;
  #       disk = 1;
  #       memory = 1;
  #       arch = "aarch64";
  #       runtime = "docker";
  #       hostname = "test";
  #       kubernetes = {
  #         enabled = true;
  #       };
  #       #autoActivate = true;
  #       network.address = true;
  #       # forwardAgent: false
  #       # docker: {}
  #       # vmType: qemu
  #       # rosetta: false
  #       # mountType: sshfs
  #       # mountInotify: false
  #       # cpuType: host
  #       # provision: []
  #       # sshConfig: true
  #       # mounts: []
  #       # env: {}
  #     }
  #   ];
  # };

}
