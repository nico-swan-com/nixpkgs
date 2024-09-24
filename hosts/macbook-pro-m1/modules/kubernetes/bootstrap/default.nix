{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.kubernetes.bootstrap;

  # Define a function to find all files in a directory
  findFiles = dir: builtins.filter (path: builtins.pathExists path) (builtins.attrValues (builtins.readDir dir));


  helmfile = lib.readFile ./helmfile.yaml;
  apps = findFiles ./apps;
  value = findFiles ./values;

in
{
  options.services.kubernetes.bootstrap = {
    options.services.cygnus-labs.kubernetes.bootstrap = {
      enable = mkEnableOption "Enable bootstrap configuration for kubernetes.";
    };

    config = mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/helmfiles 0755 root root -"
      ];


    };
  }

