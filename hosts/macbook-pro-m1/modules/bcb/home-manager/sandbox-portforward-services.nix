{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.bcb.port-forward;
  
  configFile="${config.home.homeDirectory}/.config/bcb/services/bcb-portforward-sandbox-services.yaml";
  mappingFile="${config.home.homeDirectory}/.config/bcb/services/bcb-portforward-sandbox-services-mapping.json";

  fetchServicesScript = pkgs.writeScript "fetch-services" ''
    echo "$(date) Fetching services from Kubernetes..."
    services=$(kubectl --context ${cfg.k8sContext} -n ${cfg.namespace} get services -o json)
    echo $services > ${cfg.servicesFile}
    cp ${cfg.servicesFile} /tmp/fetch-services-output.json 

    configFile="${configFile}"
    mappingFile="${mappingFile}"

    rm $configFile
    rm $mappingFile
    
    echo "procs:" > "$configFile"

    port=${toString cfg.startPort}
    echo "$services" | jq -c '.items[]' | while read -r service; do
        name=$(echo "$service" | jq -r '.metadata.name')
        servicePort=$(echo "$service" | jq -r '.spec.ports[0].port')
        command="kubectl -n sandbox port-forward service/$name $port:$servicePort --address='0.0.0.0'"
         
        echo "  $name:" >> $configFile
        echo "    autostart: false" >> $configFile
        echo "    autorestart: false" >> $configFile
        echo "    shell: \" $command \"" >> $configFile

        mappingEntry="{ \"name\": \"$name\", \"port\": $port, \"servicePort\": $servicePort }"

        if [ $port -eq ${toString cfg.startPort} ]; then
          echo "{ \"services\": [ $mappingEntry " > $mappingFile
        fi
        if [ $port -gt ${toString cfg.startPort} ]; then
          echo ", $mappingEntry " >> $mappingFile
        fi

        ((port++))
    done
    echo "] }" >> $mappingFile
  '';

  updateHostsFileScript = pkgs.writeScript "update-hosts" ''
    echo "$(date) Updating hosts file..."
    
    HOSTS_FILE="/etc/hosts"
    JSON_FILE="${mappingFile}"

    # Backup the current hosts file
    cp $HOSTS_FILE $HOSTS_FILE.bak

    # Read the JSON file and update the hosts file
    jq -c '.[]' $JSON_FILE | while read -r entry; do
      IP=127.0.0.1
      HOSTNAME="$(echo $entry | jq -r '.name').${cfg.namespace}.${cfg.hostDomain}"

      # Check if the hostname already exists in the hosts file
      if grep -q "$HOSTNAME" $HOSTS_FILE; then
        # Update the existing entry
        sed -i.bak "/$HOSTNAME/c\\$IP $HOSTNAME" $HOSTS_FILE
      else
        # Add the new entry
        echo "$IP $HOSTNAME" >> $HOSTS_FILE
      fi
    done
  '';

  readService = pkgs.runCommand "fetch-services-output.json" { } ''
    if [ -f /tmp/fetch-services-output.json ]; then
      cp /tmp/fetch-services-output.json $out
    else
      echo "{ \"items\" : []}" > $out
    fi
  '';

  readServiceMapping = pkgs.runCommand "fetch-services-mapping-output" { } ''
    if [ -f ${mappingFile} ]; then
      cp ${mappingFile} $out
    else
      echo "[]" > $out
    fi
  '';
  
  servicesJson = builtins.fromJSON (builtins.readFile readService);
  serviceMappingJson = builtins.fromJSON (builtins.readFile readServiceMapping);

  generateHostEntries = map
    (service:
      let
        hostName = "${service.name}.${cfg.namespace}.${cfg.hostDomain}";
      in
      if servicePorts == [ ] then null else {
        name = service.name;
        port = service.port;
        servicePort = service.servicePort;
        hostEntry = ''
          127.0.0.1 ${hostName}
        '';
        dnsEntry = ''
          address=/${hostName}/127.0.0.1
        '';
        nginxConfig = ''
          server {
            listen 80;
            server_name ${hostName};

            location / {
              proxy_pass http://127.0.0.1:${hostPort};
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            }
          }
        '';
      })
    serviceMappingJson;

in
{


  options.services.bcb.port-forward = {
    enable = mkEnableOption "Enable bcb services via mprocs.";

    k8sContext = mkOption {
      type = types.str;
      description = "The Kubernetes context to use.";
      default = "gke_bcb-group-sandbox_europe-west2_sandbox";
    };

    k8sProject = mkOption {
      type = types.str;
      description = "The Kubernetes project.";
      default = "bcb-group-sandbox";
    };

    servicesFile = mkOption {
      description = "The json file that contains all the services.";
      type = types.str;
      default = "${config.home.homeDirectory}/.config/bcb/fetch-services-output.json";
    };

    namespace = mkOption {
      type = types.str;
      description = "The Kubernetes namespace to query.";
      default = "sandbox";
    };

    hostDomain = mkOption {
      type = types.str;
      description = "The localhost domain. this will be prefixed to the service name.";
      default = "sandbox.svc.cluster.local";
      example = "sandbox.svc.cluster.local";
    };

    refreshInterval = mkOption {
      type = types.int;
      description = "The interval in seconds to refresh the services.";
      default = 3600;
    };

    startPort = mkOption {
      type = types.int;
      description = "The port to start with on the host for assigned services.";
      default = 60000;
    };
  };

  config = mkIf cfg.enable {

    programs.zsh.initExtra = ''
        start-${cfg.namespace}-port-forward-manager() {
          mprocs -c ${configFile}
        }
      '';


    launchd = {
      enable = true;
      agents = {
        "generate-bcb-${cfg.namespace}-port-forward-services" = {
          enable = true;
          config = {
            ProgramArguments = [
              "${pkgs.bash}/bin/bash"
              "-l"
              "-c"
              "${fetchServicesScript}"
            ];
            UserName = "${config.home.username}";
            Label = "com.bcb-group.development.generate-bcb-${cfg.namespace}-port-forward-services";
            StartInterval = cfg.refreshInterval;
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/generate-bcb-${cfg.namespace}-port-forward-services.stderr.log";
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/generate-bcb-${cfg.namespace}-port-forward-services.stdout.log";
            RunAtLoad = true;
            KeepAlive = false;
            EnableTransactions = false;
          };
        };
      };
    };
  };
}

# fetchServices = pkgs.runCommand "fetch-services"
#   {
#     buildInputs = [
#       pkgs.coreutils
#       pkgs.kubectl
#       pkgs.doas
#       (pkgs.google-cloud-sdk.withExtraComponents [
#         pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
#         pkgs.google-cloud-sdk.components.kubectl
#       ])
#     ];
#   }
#   ''
#     #echo "Fetching services from Kubernetes..."
#     #export
#     #KUBECONFIG=/etc/kubernetes/config
#     #export CLOUDSDK_CONFIG=/tmp/gcloud
#     #doas - u ${config.home.username} -- kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n ${cfg.namespace} get services -o json > /tmp/fetch-services-output.json
#     cat /tmp/fetch-services-output.json
#   '';

#   fetchServices = pkgs. "fetch-services"
#     {
#       # Specify any dependencies or environment variables here
#       buildInputs = [ pkgs.coreutils ];
#     }
#     ''
#       export KUBECONFIG=${config.home.homeDirectory}/.kube/config
# sudo -u ${config.home.username} -- ${pkgs.kubectl}/bin/kubectl --context ${cfg.k8sContext} -n ${cfg.namespace} get services -o json > $out
#     '';

