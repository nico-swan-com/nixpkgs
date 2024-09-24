{ config, ...}:
{

  imports = [
    ../../../modules/bcb/home-manager/mropcs-services-config-files.nix
    ../../../modules/bcb/home-manager/sandbox-portforward-services.nix
  ];

  services.bcb.port-forward.enable = true;

  services.bcb.process-manager = {
    enable = true;
    services = [
      {
        name = "admin-console-services";
        procs = [
          {
            name = "sandbox-entitlements";
            autostart = true;
            autorestart = true;
            shell = "kubectl -n sandbox port-forward service/entitlements-grpc 50051:50051 --address='0.0.0.0'";
          }
          {
            name = "admin-api";
            shell = "direnv exec . npm run start:dev";
            cwd = "${config.home.homeDirectory}/Developer/src/admin-api";
            autostart = true;
            autorestart = true;
            env = {
              NODE_ENV="local";
            };
          }
          {
            name= "services";
            autostart = false;
            autorestart = false;
            cwd = "${config.home.homeDirectory}/Developer/src/bcb-services";
            shell = "direnv exec . npm run start:local";
            env = {
              NODE_ENV="local";
              NODE_VERSION_PREFIX="v";
              NODE_VERSIONS ="~/.nvm/versions/node";
              GOOGLE_SERVICE_KEY_PATH =" ${config.home.homeDirectory}/Developer/src/bcb-services/.devcontainer/bcb-services.json";
              GOOGLE_APPLICATION_CREDENTIALS = " ${config.home.homeDirectory}/Developer/src/bcb-services/.devcontainer/bcb-services.json";
            };
          }
          {
            name = "sandbox-heimdall";
            autostart = true;
            autorestart = true;
            shell = "kubectl -n sandbox port-forward service/heimdall 8080:8080 --address='0.0.0.0'";
          }
        ];
      }
    ];
  };
}