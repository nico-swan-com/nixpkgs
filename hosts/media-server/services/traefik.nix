let
  email = "hi@nicoswan.com";
  dataDir = "/data/services/traefik";
  certResolverName = "nicoswan-com-resolver";
in
{
  systemd.services.traefik.serviceConfig.WorkingDirectory = "${dataDir}";
  services.traefik = {
    enable = true;
    dataDir = "${dataDir}";
    staticConfigOptions = {
      api = {
        insecure = true;
        dashboard = true;
      };
      entryPoints = {
        web = {
          address = ":80";
          reusePort = true;
        };
        websecure = {
          address = ":443";
          reusePort = true;
          #http.tls.certResolver = "${certResolverName}";
        };
        traefik = {
          address = ":8080";
          #http.tls.certResolver = "${certResolverName}";
        };
      };
      experimental.plugins = {
        fail2ban = {
          moduleName = "github.com/tomMoulard/fail2ban";
          version = "v0.8.1";
        };
      };

      certificatesResolvers.${certResolverName}.acme = {
        email = "${email}";
        storage = "${dataDir}/acme.json";
        httpChallenge = {
          # used during the challenge
          entryPoint = "web";
        };
      };

    };
    dynamicConfigOptions = {
      http = {
        routers = {
          plex = {
            rule = "Host(`plex.home.nicoswan.com`)";
            tls.certResolver = "${certResolverName}";
            service = "service-plex";
          };
        };
        services = {
          service-plex = {
            loadBalancer.servers = [{ url = "http://127.0.0.1:32400/web/"; }];
          };
        };
      };
    };
  };
}

# staticConfigFile = builtins.toFile "static_config.toml" ''
#   ################################################################
#   #
#   # Configuration sample for Traefik v2.
#   #
#   # For Traefik v1: https://github.com/traefik/traefik/blob/v1.7/traefik.sample.toml
#   #
#   ################################################################

#   ################################################################
#   # Global configuration
#   ################################################################
#   [global]
#     checkNewVersion = true
#     sendAnonymousUsage = false

#   ################################################################
#   # Entrypoints configuration
#   ################################################################

#   # Entrypoints definition
#   #
#   # Optional
#   # Default:
#   [entryPoints]
#     [entryPoints.web]
#       address = ":80"

#     [entryPoints.websecure]
#       address = ":443"

#   ################################################################
#   # Traefik logs configuration
#   ################################################################

#   # Traefik logs
#   # Enabled by default and log to stdout
#   #
#   # Optional
#   #
#   [log]

#     # Log level
#     #
#     # Optional
#     # Default: "ERROR"
#     #
#     # level = "DEBUG"

#     # Sets the filepath for the traefik log. If not specified, stdout will be used.
#     # Intermediate directories are created if necessary.
#     #
#     # Optional
#     # Default: os.Stdout
#     #
#     # filePath = "log/traefik.log"

#     # Format is either "json" or "common".
#     #
#     # Optional
#     # Default: "common"
#     #
#     # format = "json"

#   ################################################################
#   # Access logs configuration
#   ################################################################

#   # Enable access logs
#   # By default it will write to stdout and produce logs in the textual
#   # Common Log Format (CLF), extended with additional fields.
#   #
#   # Optional
#   #
#   # [accessLog]

#     # Sets the file path for the access log. If not specified, stdout will be used.
#     # Intermediate directories are created if necessary.
#     #
#     # Optional
#     # Default: os.Stdout
#     #
#     # filePath = "/path/to/log/log.txt"

#     # Format is either "json" or "common".
#     #
#     # Optional
#     # Default: "common"
#     #
#     # format = "json"

#   ################################################################
#   # API and dashboard configuration
#   ################################################################

#   # Enable API and dashboard
#   [api]

#     # Enable the API in insecure mode
#     #
#     # Optional
#     # Default: false
#     #
#     # insecure = true

#     # Enabled Dashboard
#     #
#     # Optional
#     # Default: true
#     #
#     # dashboard = false

#   ################################################################
#   # Ping configuration
#   ################################################################

#   # Enable ping
#   [ping]

#     # Name of the related entry point
#     #
#     # Optional
#     # Default: "traefik"
#     #
#     # entryPoint = "traefik"

#   ################################################################
#   # Docker configuration backend
#   ################################################################

#   # Enable Docker configuration backend
#   #[providers.docker]

#     # Docker server endpoint. Can be a tcp or a unix socket endpoint.
#     #
#     # Required
#     # Default: "unix:///var/run/docker.sock"
#     #
#     # endpoint = "tcp://10.10.10.10:2375"

#     # Default host rule.
#     #
#     # Optional
#     # Default: "Host(`{{ normalize .Name }}`)"
#     #
#     # defaultRule = "Host(`{{ normalize .Name }}.docker.localhost`)"

#     # Expose containers by default in traefik
#     #
#     # Optional
#     # Default: true
#     #
#     # exposedByDefault = false    


# '';
