{ config, pkgs, ... }:
let
  vectorConfig = (builtins.readFile ./vector.yaml);
in
{
  # List system packages only for MacOS 
  environment.systemPackages = with pkgs; [
    vector
  ];

  environment.etc = {
    "vector/vector.yaml" = {
      text = vectorConfig;
    };
  };
}
