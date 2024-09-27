{ config, lib, pkgs, configVars, ... }:

with lib;

let
  cfg = config.services.nginx;
in
{


  options.services.nginx = {
    enable = mkEnableOption "Enable nginx proxy.";

    vhostDirectories = mkOption {
      type = types.listOf types.str;
      description = "The directories to look for vhost configurations.";
      default = [ "/etc/nginx/vhosts" ];
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      nginx
    ];

    environment.etc = {
      
      "nginx/conf/nginx.conf".text = ''
      daemon off;
      worker_processes  1;
      events {
          worker_connections  1024;
      }
      http {
          include /etc/nginx/vhosts/*.conf;
          ${lib.concatStringsSep "\n" (builtins.map (vhostDirectory: "include ${vhostDirectory}/*.conf;") cfg.vhostDirectories)}
          include ${pkgs.nginx}/conf/mime.types;
          default_type  application/octet-stream;
          sendfile        on;
          keepalive_timeout  65;

          server {
            listen 80 default_server;
            return 502;
          }
        }
      
      '';
    };

    launchd = {
      daemons = {
        "nginx-service-proxy" = {
          script = ''
            if ! test -e /etc/nginx; then
                mkdir -p /etc/nginx
                cp -R ${pkgs.nginx}/conf/* /etc/nginx/conf/
            fi

            if ! test -e /etc/nginx/vhosts; then
                mkdir -p /etc/nginx/vhosts
            fi

            if ! test -e /var/log/nginx; then
              mkdir /var/log/nginx
            fi
            ${pkgs.nginx}/bin/nginx -c /etc/nginx/conf/nginx.conf
            ${pkgs.nginx}/bin/nginx -s reload
          '';
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            EnableTransactions = true;
            Label = "com.bcb-group.development.bcb.nginx-service-proxy";
            StandardErrorPath = "/etc/nginx/launchd.stderr.log";
            StandardOutPath = "/etc/nginx/launchd.stdout.log";
          };
        };
      };
    };
  };
}
