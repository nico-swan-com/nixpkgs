{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.nicoswan.utils.google-cloud-sdk;
in
{

  options.programs.bcb.utils.google-cloud-sdk = {
    enable = mkEnableOption "Enable google-cloud-sdk.";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.cloud_sql_proxy
        google-cloud-sdk.components.pubsub-emulator
      ])
    ];

    programs.zsh = {
      sessionVariables = {
        CLOUD_SDK_HOME = "${pkgs.google-cloud-sdk}";
        GOOGLE_APPLICATION_CREDENTIALS = "${config.home.homeDirectory}/.config/gcloud/application_default_credentials.json";
        GOOGLE_SERVICE_KEY_PATH = "${config.home.homeDirectory}/.config/gcloud/application_default_credentials.json";
      };
      # Configure  google-cloud-sdk auto complete 
      initExtra = ''
        source "$CLOUD_SDK_HOME/google-cloud-sdk/path.zsh.inc"
      '';
    };

  };
}
