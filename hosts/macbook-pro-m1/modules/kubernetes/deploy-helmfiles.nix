{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.kubernetes.deploy-helmfiles;

  releaseType = lib.types.submodule {
    options = {
          name = mkOption {
            description = "The name of the helm release";
            type = types.str;
          };

          colimaInstance  = mkOption {
            description = "Name of colima instance";
            type = types.str;
          };


          version = mkOption {
            description = "The version of the helm release";
            type = types.str;
          };

          namespace = mkOption {
            description = "The namespace for the helm release";
            type = types.str;
          };

          chart = mkOption {
            description = "The helm chart name.";
            type = types.str;
          };

          values = mkOption {
            description = "The helm chart values.";
            type = types.attrsOf types.attrs;
            default = { };
          };
    };

  };

  deplomentName = release: "${release.namespace}.${release.name}.${release.version}";

  generateHelmFile = release: pkgs.runCommand "${deplomentName release}.yaml" { } ''
    echo ${builtins.toJSON release} | ${pkgs.remarshal}/bin/json2yaml -o $out
  '';

  configJSON = release: pkgs.writeText "${deplomentName release}.json" (builtins.toJSON release);
  helmFile = release: pkgs.runCommand "${deplomentName release}.yaml" { } ''
    ${pkgs.remarshal}/bin/json2yaml -i ${configJSON release} -o $out
  '';

  # helmfileJson = release: pkgs.writeText "${deplomentName release}.json" builtins.toJSON release;
  # helmfileYaml = release: pkgs.runCommand "${deplomentName release}.yaml"
  #   {
  #     buildInputs = [ pkgs.yj ];
  #     json = helmfileJson release;
  #     passAsFile = [ "json" ];
  #   } ''
  #   mkdir -p $out
  #   echo "$json" > $out/${cfg.name}.json
  #   yj -jy < $out/${cfg.name}.json > $out/${cfg.name}.yaml
  # '';

    startScript = release: pkgs.writeScriptBin "deploy-${deplomentName release}.sh" ''
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/run/current-system/sw/bin"
    
    # wait until colima is running
    while true; do
      ${pkgs.colima}/bin/colima -p ${release.colimaInstance} status &>/dev/null
      if [ $? -eq 0 ]; then
        break
      fi

      ${pkgs.helmfile}/bin/helmfile -f ${helmFile release} -e ${release.environment} -n ${release.namespace} -s ${release.deployment} apply
      sleep 5
    done

    tail -f /dev/null &
    wait $!
  '';


in
{
  options.services.kubernetes.deploy-helmfiles = {
    options.services.cygnus-labs.kubernetes.cluster.storage = {
    enable = mkEnableOption "Enable helmfile configuration.";

    name = mkOption {
      type = types.str;
      description = "The name for the helmfile configuration.";
      default = "";
    };

    repositories = mkOption {
      type = types.str;
      description = "The helmfile repositories.";
      default = "";
    };

    releases = mkOption {
      type = types.listOf releaseType;
    };

    refreshInterval = mkOption {
      type = types.int;
      description = "The interval in seconds to refresh the services.";
      default = 3600;
    };
  };

  config = mkIf cfg.enable {
    

  home.file = lib.mkMerge (map
  (vm: {
      ".config/helmfiles/".text = builtins.readFile (configFile vm);
   })
   cfg.releases);


    # launchd = {
    #   enable = true;
    #   agents = lib.mkMerge (map
    #     (vm: {
    #       "${vm.hostname}" = {
    #         enable = vm.enable;
    #         config = {
    #           ProgramArguments = [
    #             "${pkgs.bash}/bin/bash"
    #             "-l"
    #             "-c"
    #             "${startScript}"
    #           ];
    #           StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/colima-${vm.hostname}.stderr.log";
    #           StandardOutPath = "${config.home.homeDirectory}/Library/Logs/colima-${vm.hostname}.stdout.log";
    #           RunAtLoad = true;
    #           KeepAlive = true;
    #           EnableTransactions = true;
    #         };
    #       };
    #     })
    #     cfg.vms);
    # };
  };
}


{ config, lib, pkgs, configVars, ... }:

with lib;

let
  cfg = config.services.cygnus-labs.kubernetes.deploy-helmfiles;

  
in
{


  