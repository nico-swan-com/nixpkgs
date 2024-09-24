{ pkgs,lib, ...}:
let
  bcb-sandbox-kubernetes-context = "gke_bcb-group-sandbox_europe-west2_sandbox";
in
{

  imports = [
    ./custom-zsh-functions.nix
  ];

  home.packages = with pkgs; [
    terminal-notifier
    kail
    ktop
  ];

  programs.zsh = {
    shellAliases = {
      # Database
      db_prod = "cloud_sql_proxy -enable_iam_login -instances=bcb-group:europe-west2:bcb-production=tcp:3307,bcb-group:europe-west2:bcb-pg1=tcp:15432";
      db_sandbox = "cloud_sql_proxy -enable_iam_login -instances=bcb-group-sandbox:europe-west2:bcb-pg1=tcp:15432,bcb-group-sandbox:europe-west2:sandbox=tcp:3307";

      #Kubernetes
      kube-sandbox-context = lib.mkDefault "kubectl config use-context ${bcb-sandbox-kubernetes-context}";
      ksandbox = lib.mkDefault "kubectl --context ${bcb-sandbox-kubernetes-context} -n sandbox";

    };

    sessionVariables = {
      NVM_DIR = "$HOME/.nvm";
    };

    initExtra = ''
      
    '';
  };
}
