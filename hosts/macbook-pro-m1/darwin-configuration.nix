{ pkgs, configVars, ... }:
{
  imports = [
    # Core must have system installations
    ../common/core
    ./system

    # BCB Services
    ./services/system/bcb
    ./services/databases/postgres.nix

    # Custom modules
    ./modules/tools/gefyra

    #./modules/coredns.nix
    #./modules/kubernetes/k0s.nix

  ];

   
  ids.uids.nixbld = 351;


  # List system packages only for MacOS 
  environment.systemPackages = with pkgs; [
    terminal-notifier # send notification from the terminal
    fswatch
    #open-interpreter # OpenAI's Code Interpreter in your terminal, running locally
    mprocs #TUI to start processes
    #coredns # DNS server
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.cloud_sql_proxy
      google-cloud-sdk.components.pubsub-emulator
      google-cloud-sdk.components.kubectl
    ])

    #traefik # Reverse proxy
    #nginx # Reverse proxy

    # Kubernetes
    kubernetes-helm
    k9s
    helmfile
    (wrapHelm kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-secrets
        helm-diff
        helm-s3
        helm-git
      ];
    })

  ];

   # Set /etc/zshrc
  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  programs.gefyra.enable = true;

}
