{ config, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    lima
  ];

}
