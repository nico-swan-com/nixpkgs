{ pkgs, cfg, ... }:
{
  # Install extra systemPackages
  environment.systemPackages = with pkgs; [
    git-extras
    cowsay
    lunarvim
  ];

  # Install nginx proxy configured with vhost directrectory to add additioanl host configs 
  # Nginx for MacOS
  services.nginx = {
    enable = true;
    vhostDirectories = [ "/User/${cfg.username}/.config/nginx/vhosts" ];
  };

}

