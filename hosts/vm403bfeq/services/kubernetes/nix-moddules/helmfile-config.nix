

{ config, lib, pkgs, configVars,... }:

with lib;

let
  cfg = config.services.cygnus-labs.kubernetes.config;

  helmfileJson = pkgs.writeText "${cfg.name}.json" builtins.toJSON cfg;
  helmfileYaml = pkgs.runCommand "${name}.yaml" {
        buildInputs = [ pkgs.yj ];
        json = helmfileJson;
        passAsFile = [ "json" ];
      } ''
        mkdir -p $out
        echo "$json" > $out/${cfg.name}.json
        yj -jy < $out/${cfg.name}.json > $out/${cfg.name}.yaml
      '';
in
{


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
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "The name of the helm release";
           };

           namespace = mkOption {
            type = types.str;
            description = "The namespace for the helm release";
           };

          chart = mkOption {
            type = types.str;
            description = "The helm chart name.";
           };

           values = mkOption {
            type = types.json;
            description = "The helm chart values.";
            default = {};
           };
        };
        });
        };


    refreshInterval = mkOption {
      type = types.int;
      description = "The interval in seconds to refresh the services.";
      default = 3600;
    };

  };

  config = mkIf cfg.enable {

    helmfile = createHelmfile

  };
}
