{ config, lib, pkgs,... }:

with lib;

let
  cfg = config.services.bcb.host-updater;
in
{


  options.services.bcb.host-updater = {
    enable = mkEnableOption "Enable bcb services via mprocs.";

    userHome = mkOption {
      type = types.str;
      description = "The user home directory.";
    };

    mappingFile = mkOption {
      type = types.str;
      description = "The json mapping file path.";
      default = "${cfg.userHome}/.config/bcb/services/bcb-portforward-sandbox-services-mapping.json";
    };

    namespace = mkOption {
      type = types.str;
      description = "The namespace the services are under.";
      default = "sandbox";
    };

    hostDomain = mkOption {
      type = types.str;
      description = "The localhost domain. this will be prefixed to the service name and the namespace.";
      default = "svc.cluster.local";
      example = "svc.cluster.local";
    };

    refreshInterval = mkOption {
      type = types.int;
      description = "The interval in seconds to refresh the services.";
      default = 3600;
    };

    dnsBindIp = mkOption {
      type = types.str;
      description = "The address to bind the DNS server to.";
      default = "127.0.0.1";
    };

    dnsPort = mkOption {
      type = types.int;
      description = "The DNS port to bind to.";
      default = 53;
    };

    vhostDirectory = mkOption {
      type = types.str;
      description = "The directory to look for vhost configurations.";
      default = "/etc/nginx/vhosts";
    };

  };

  config = mkIf cfg.enable {

    launchd = {
      daemons = {
        "update-hosts-bcb-${cfg.namespace}" = {
          script = ''
  # Ensure the ~/.config/bcb/vhosts/etc/nginx/vhosts directory exists
  if [ ! -d ${cfg.userHome}/.config/bcb/nginx/vhosts ]; then
      sudo mkdir -p ${cfg.userHome}/.config/bcb/nginx/vhosts/
  fi

  # Ensure the /etc/resolver directory exists
  if [ ! -d /etc/resolver ]; then
    sudo mkdir /etc/resolver
  fi

  echo "$(date) Updating hosts file..."
  
  HOSTS_FILE="/etc/hosts"
  JSON_FILE="${cfg.mappingFile}"
  DNS_ADRESSES=" "

  # Backup the current hosts file
  cp $HOSTS_FILE $HOSTS_FILE.bak

  # Read the JSON file and update the hosts file
  ${pkgs.jq}/bin/jq -c '.services[]' $JSON_FILE | while read -r entry; do
    IP=${cfg.dnsBindIp}
    SERVICE_HOSTNAME="$(echo $entry | ${pkgs.jq}/bin/jq -r '.name').${cfg.namespace}.${cfg.hostDomain}"
    PORT="$(echo $entry | ${ pkgs.jq}/bin/jq -r '.port')"
    DNS_ADRESSES="$DNS_ADRESSES --address=/$SERVICE_HOSTNAME/$IP"
    
    # Check if the hostname already exists in the hosts file
    if grep -q "$SERVICE_HOSTNAME" $HOSTS_FILE; then

      # Update the existing entry
      # echo "$(date) sed -i.bak \"/$SERVICE_HOSTNAME/c\\${cfg.dnsBindIp} $SERVICE_HOSTNAME\" \"$HOSTS_FILE\""
      ESCAPED_HOST=$(echo "$SERVICE_HOSTNAME" | sed 's/\./\\./g')
      sed -i.bak "/$ESCAPED_HOST/c\\ $IP $ESCAPED_HOST" "$HOSTS_FILE"

    else
      # Add the new entry
      echo "$IP $SERVICE_HOSTNAME" >> $HOSTS_FILE
    fi
    
    NGINX_VHOST_CONFIG_FILE="/etc/nginx/vhosts/$SERVICE_HOSTNAME.conf"
    # Create the configuration content
    cat <<EOL > $NGINX_VHOST_CONFIG_FILE
  server {
      listen 80;
      server_name $SERVICE_HOSTNAME;

      location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
      }
    }
EOL
  done

  RESOLVER_FILE="/etc/resolver/${cfg.hostDomain}"
  # Create or overwrite the resolver file with the DNS server configuration
  echo "$(date) Creating resolver file for $SERVICE_HOSTNAME"
  echo "domain ${cfg.hostDomain}" > $RESOLVER_FILE
  echo "search ${cfg.hostDomain}" >> $RESOLVER_FILE
  echo "nameserver ${cfg.dnsBindIp}" >> $RESOLVER_FILE

  echo "$(date) Resolver file for ${cfg.hostDomain} created at $RESOLVER_FILE"
  killall - HUP mDNSResponder

  echo "$(date) Updating dnsmaq with addresses"
  ${pkgs.dnsmasq}/bin/dnsmasq --test --listen-address=${cfg.dnsBindIp} --port=${toString cfg.dnsPort} --keep-in-foreground $DNS_ADRESSES
          '';
          serviceConfig = {
            KeepAlive = false;
            RunAtLoad = true;
            Label = "com.bcb-group.development.bcb.host-updater-${cfg.namespace}";
            StartInterval = cfg.refreshInterval;
            EnableTransactions = true;
            StandardErrorPath = "${cfg.userHome}/Library/Logs/update-bcb-${cfg.namespace}.stderr.log";
            StandardOutPath = "${cfg.userHome}/Library/Logs/update-bcb-${cfg.namespace}.stdout.log";
          };
        };
      };
    };
  };
}
