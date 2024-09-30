{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.nicoswan.database.postgres;

  createUserScript = pkgs.writeScript "createUser" ''
    # Check if the role exists
    ROLE_EXISTS=$(psql -U postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='${cfg.username}'")

    # If the role does not exist, create it
    if [ -z "$ROLE_EXISTS" ]; then
       psql -U postgres -qc "CREATE ROLE ${cfg.username} LOGIN PASSWORD '${cfg.password}';"
       echo "Postgres role '${cfg.username}' created with password."
    else
      # If the role exists, assign the password
      psql -U postgres -qc "ALTER ROLE ${cfg.username} WITH PASSWORD '${cfg.password}';"
      echo "Postgres password for role '${cfg.username}' has been updated."
    fi

    # Check if the database exists
    DB_EXISTS=$(psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${cfg.username}'")

    # If the database does not exist, create it
    if [ -z "$DB_EXISTS" ]; then
       psql -U postgres -qc "CREATE DATABASE ${cfg.username} OWNER ${cfg.username};"
       echo "Postgres database '${cfg.username}' created and owned by role '${cfg.username}'."
    fi
  '';
in
{

  options.services.nicoswan.database.postgres = {
    enable = mkEnableOption "Enable Nico Swan postgres database.";
    package = mkOption {
      description = "The package to use for postgres.";
      type = types.package;
      default = pkgs.postgresql_16;
      defaultText = literalExpression "pkgs.postgresql_16";
    };
    port = mkOption {
      description = "The port to listen on.";
      type = types.int;
      default = 5432;
    };
    dataDir = mkOption {
      description = "The location of the postgres data.";
      type = types.str;
      default = "/usr/local/var/postgres";
    };
    username = mkOption {
      description = "The username for the host.";
      type = types.str;
    };
    password = mkOption {
      description = "The user password.";
      type = types.str;
      default = "password";
    };
  };

  config = mkIf cfg.enable {



    services.postgresql = {
      enable = true;
      package = cfg.package;
      dataDir = "${cfg.dataDir}/${cfg.package.version}";
      enableTCPIP = true;
      settings = {
        port = cfg.port;
        listen_addresses = "*";
      };
      initdbArgs = [ "--pgdata=${cfg.dataDir}/${cfg.package.version}" "--auth=trust" "--no-locale" "--encoding=UTF8" ];
      extraPlugins = with cfg.package.pkgs; [
        rum
        timescaledb
        pgroonga
        wal2json
        pg_repack
        pg_safeupdate
        plpgsql_check
        pgjwt
        pgaudit
        postgis
        pgrouting
        pgtap
        pg_cron
        pgsql-http
        pg_net
        pgsodium
        pgvector
        hypopg
      ];
      authentication = pkgs.lib.mkOverride 10 ''
        #type    database DBuser  origin-address auth-methoda
        local    all      all                    trust
        # ipv4
        host     all      all     127.0.0.1/32   trust
        host     all      all     0.0.0.0/0      md5
        # ipv6
        host     all      all     ::1/128        trust
        host     all      all     ::1/0          md5
      '';
      identMap = ''
        # ArbitraryMapName systemUser DBUser
        superuser_map      root                    postgres
        superuser_map      postgres                postgres
        superuser_map      ${cfg.username}         postgres
        # Let other names login as themselves
        superuser_map      /^(.*)$   \1
      '';
    };

    # Create the PostgreSQL data directory, if it does not exist.
    system.activationScripts.preActivation = {
      enable = true;
      text = ''
        if [ ! -d "${cfg.dataDir}" ]; then
          echo "creating PostgreSQL data directory..."
          sudo mkdir -m 775 -p ${cfg.dataDir}
          chown -R ${cfg.username}:staff ${cfg.dataDir}
        fi
      '';
    };

    system.activationScripts.postActivation = {
      enable = true;
      text = '' ${createUserScript} '';
    };


    launchd.user.agents.postgresql.serviceConfig = {
      StandardErrorPath = "/Users/${cfg.username}/Library/Logs/postgres.error.log";
      StandardOutPath = "/Users/${cfg.username}/Library/Logs/postgres.out.log";
    };

  };
}
