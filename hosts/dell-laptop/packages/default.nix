{ pkgs, configVars, ... }:
{
  imports = [
    ./programs.nix
    #./ai.nix
    ../../../modules/cygnus-labs/read-aloud
  ];

  gnome-read-aloud = {
    enable = true;
    user = configVars.username;
    #model-voice = "/home/nicoswan/Downloads/en_GB-alan-medium.onnx";
  };

  environment.systemPackages = with pkgs; [
    vim

    epson-escpr2
    epson-escpr

    # Kubernetes tools
    kubectl
    kompose
    k9s

    # gnome.polari
    gnome-builder
  ];
}
