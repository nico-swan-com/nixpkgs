{
  services.fail2ban = {
    enable = true;
    # Ban IP after 5 failures
    maxretry = 5;
    ignoreIP = [
      # Whitelist some subnets
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      # whitelist a specific IP
      "8.8.8.8"
      "102.33.35.54"
    ];
    bantime = "24h"; # Ban IPs for one day on the first ban
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      multipliers = "1 2 4 8 16 32 64";
      # maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
    jails = {
      sshd.settings = {
        mode = "aggressive";
        publickey = "invalid";
      };
      # ngnix-url-probe.settings = {
      #   enabled = true;
      #   filter = "nginx-url-probe";
      #   logpath = "/var/log/nginx/access.log";
      #   action = ''%(action_)s[blocktype=DROP]
      #            ntfy'';
      #   backend = "auto"; # Do not forget to specify this if your jail uses a log file
      #   maxretry = 5;
      #   findtime = 600;
      # };
      # apache-nohome-iptables.settings = {
      #   # Block an IP address if it accesses a non-existent
      #   # home directory more than 5 times in 10 minutes,
      #   # since that indicates that it's scanning.
      #   filter = "apache-nohome";
      #   action = ''iptables-multiport[name=HTTP, port="http,https"]'';
      #   logpath = "/var/log/httpd/error_log*";
      #   backend = "auto";
      #   findtime = 600;
      #   bantime = 600;
      #   maxretry = 5;
      # };
    };
  };
}
