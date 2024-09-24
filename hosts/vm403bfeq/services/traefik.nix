{ config, pkgs, ... }:

let
  cloudflareEnvFile = "${config.sops.secrets."servers/cygnus-labs/services/cloudflare/envFile".path}";
  cloudflareEmail = "nico.swan@cygnus-labs.com";
in
{

  security.acme = {
      acceptTerms = true;
      defaults.email = "${cloudflareEmail}";
      certs."cygnus-labs.com" = {
        domain = "cygnus-labs.com";
        extraDomainNames = [ "*.cygnus-labs.com" "*.services.cygnus-labs.com" ];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        credentialsFile = "${cloudflareEnvFile}";
      };
    };

  
  sops = {
    secrets = {
      "servers/cygnus-labs/services/cloudflare/email" = {};
      "servers/cygnus-labs/services/cloudflare/envFile" = {};
    };
  };

  users.users.traefik.extraGroups = [ "docker" "podman" "acme" ];
  networking.extraHosts =
  ''
    127.0.0.1 services.cygnus-labs.com
    127.0.0.1 production.cygnus-labs.com
  '';

  services.traefik = {
    enable = true;
    # Static configuration for Traefik
    staticConfigOptions = {
      log.level="INFO";
      # api = {
      #   dashboard = true;
      #   # insecure = true;
      # }; 

      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };
      
      entryPoints = {
          web = {
            address = ":80";
            http.redirections.entrypoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure = {
            address = ":443";
          };
      };
      #providers.docker.exposedByDefault = false;
      #providers.docker = true;
      certificatesResolvers = {
        cloudflare = {
          acme = {
            email = "${cloudflareEmail}";
            storage = "/etc/traefik/acme/acme-cloudflare.json";
            dnsChallenge = {
              provider = "cloudflare";
              delayBeforeCheck = 0;
            };
          };
        };
      };
    };
    # Dynamic configuration for Traefik
    dynamicConfigOptions = {
        tls = {
          stores.default = {
            defaultCertificate = {
            certFile = "/var/lib/acme/cygnus-labs.com/cert.pem";
            keyFile = "/var/lib/acme/cygnus-labs.com/key.pem";
          };
        };

        certificates = [
          {
            certFile = "/var/lib/acme/cygnus-labs.com/cert.pem";
            keyFile = "/var/lib/acme/cygnus-labs.com/key.pem";
            stores = "default";
          }
        ];
      };
      http = {
        middlewares = {
          addCNHeader = {
            headers = {
              customRequestHeaders = {
                "X-Client-CN" = "{tls.client.subject.commonName}";
              };
            };
          };
          # auth = {
          #   basicAuth = {
          #     users =[
          #          "test:$apr1$H6uskkkW$IgXLP6ewTrSuBkTrqE8wj/"
          #          "test2:$apr1$d9hr9HBB$4HxwgUir3HP4EsggP/QNo0"
          #     ];
          #   };
          # };
        };
    
        routers = {
          # dashboard ={
          #   rule = "Host(`api.cygnus-labs.com`)";
          #   service = "api@internal";
          #   middlewares = ["auth"];
          # };

          to-k8s-websecure = {
            entryPoints = ["websecure"];
            rule = "HostRegexp(`[a-zA-Z0-9-]+\\.services\\.cygnus-labs\\.com`)";
            service = "k8s-service-websecure";
            tls = true;
            middlewares = ["addCNHeader"];
            # tls = {
            #   certResolver = "cloudflare";
            # };
          };

          to-k8s-web = {
            entryPoints = ["web"];
            rule = "HostRegexp(`[a-zA-Z0-9-]+\.services\.cygnus-labs\.com`)";
            service = "k8s-service-web";
            middlewares = ["addCNHeader"];
          };

          # to-podman-websecure = {
          #   entryPoints = ["websecure"];
          #   rule = "HostRegexp(`[a-zA-Z0-9-]+\\.production\\.cygnus-labs\\.com`)";
          #   service = "podman-services-websecure";
          #   tls = true;
          #   middlewares = ["addCNHeader"];
          #   # tls = {
          #   #   certResolver = "cloudflare";
          #   # };
          # };

          # to-podman-web = {
          #     entryPoints = ["web"];
          #     rule = "HostRegexp(`[a-zA-Z0-9-]+\\.production\\.cygnus-labs\\.com`)";
          #     service = "podman-services-web";
          # };
        };

        services = {
          "k8s-service-websecure" = {
            loadBalancer = {
              servers = [
                { url = "https://whoami.services.cygnus-labs.com:10443"; }
              ];
            };
          };

          "k8s-service-web" = {
            loadBalancer = {
              servers = [
                { url = "http://services.cygnus-labs.com:10080"; }
              ];
            };
          };


          # "podman-services-websecure" = {
          #   loadBalancer = {
          #     servers = [
          #       { url = "http://127.0.0.1:8080"; }
          #     ];
          #   };
          # };

          # "podman-services-web" = {
          #   loadBalancer = {
          #     servers = [
          #       { url = "http://127.0.0.1:8080"; }
          #     ];
          #   };
          # };
        };
      };
    };
    environmentFiles = [
      "${cloudflareEnvFile}"
    ];
  };
}
