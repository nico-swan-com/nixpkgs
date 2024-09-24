{
  services.redis = {
    servers."cygnus-labs" = {
      enable = true;
      #user = "nextcloud";
      #unixSocket = "/run/redis-nextcloud/redis.sock";
      port = 6379;
    };
  };
}
