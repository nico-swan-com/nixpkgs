{ config, pkgs, configVars, ... }:
#let
#  password = "${config.sops.secrets."hosts//".path}";
#in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    dataDir = "/data/postgres/16";
    settings = {
      port = 5432;
      listen_addresses = "*";
    };
    ensureDatabases = [ "${configVars.username}" "test" ];
    ensureUsers = [
      {
         name = configVars.username;
         ensureDBOwnership = true;
         ensureClauses = {
           superuser = true;
           replication = true;
           login = true;
 #          inherit = true;
           createrole = true;
           createdb = true;
           bypassrls = true;
        };
      }
      {
         name = "test";
      }
    ];
    extraPlugins = with pkgs.postgresql_16.pkgs; [
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
      #plv8
      # Missing supabase plugins
      #    index_advisor
      #    pg_tle
      #    wrappers
      #    supautils
      #    pg_graphql
      #    pg_stat_monitor
      #    pg_jsonschema
      #    pg_hashids
      #    pg_plan_filter
      #    pg_backtrace
      #    vault
      
    ];
#     initialScript = pkgs.writeText "init-sql-script" ''
#       alter user test with password 'password';
#     '';
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
      superuser_map      ${configVars.username}  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';

  };

}
