{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.nicoswan.utils.kubernetes;
  in
{
  options.programs.nicoswan.utils.kubernetes = {
    enable = mkEnableOption "Enable kubernetes utilities.";
    additional-utils = mkEnableOption "Install admin tools.";
    admin-utils = mkEnableOption "Install admin tools.";
  };

  config = mkIf cfg.enable {

    programs = {
      zsh = {
        shellAliases = {
          kcontext = lib.mkDefault "kubectl config use-context";
        };
      };
    };

    home.packages = with pkgs; [
      kubectl
    ] ++ (if cfg.additional-utils then [
      k9s # Kubernetes TUI
      kns # Kubernetes namespace switcher
      kail # Kubernetes log viewer
      kubectx # Kubernetes context switcher
      ktop # Kubernetes top
    ] else [ ])
    ++ (if cfg.admin-utils then [
      kubernetes-helm
      helmfile
      (wrapHelm kubernetes-helm {
        plugins = with pkgs.kubernetes-helmPlugins; [
          helm-secrets
          helm-diff
          helm-s3
          helm-git
        ];
      })
    ] else [ ]);
  };
}
