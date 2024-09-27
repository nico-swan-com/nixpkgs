{ pkgs, config, ... }:
{

  #Import your own custom modules
  imports = [
    ./custom-modules/alacritty
  ];

  # Install addition packages via home manager
  home.packages = with pkgs; [
    glow # Terminal marckdown viewer
    fira-code-nerdfont # Font installation
  ];
}
