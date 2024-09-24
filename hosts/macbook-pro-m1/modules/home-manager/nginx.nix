{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nginx;
in
{
  options.services.nginx = {
    enable = mkOption {
      description = "Enable nginx.";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable {

      launchd = {
        enable = true;
        agents = {
          "local-nginx-proxy" = {
            enable = cfg.enable;
            config = {
              ProgramArguments = [
                "${pkgs.nginx}/bin/nginx"
                "-g"
                "daemon off;"
              ];
              Label = "local-nginx-proxy";
              StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/local-nginx-proxy.stderr.log";
              StandardOutPath = "${config.home.homeDirectory}/Library/Logs/local-nginx-proxy.stdout.log";
              RunAtLoad = true;
              KeepAlive = false;
              EnableTransactions = true;
            };
          };
        };
      };
    };
}
