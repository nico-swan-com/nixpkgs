{ config, pkgs, ... }:
{

  # environment.systemPackages = with pkgs; [
  #   colima
  # ];

  # set colima vm as default
  programs.zsh = {
    sessionVariables = {
      #COLIMA_VM="default";
      #COLIMA_VM_SOCKET="$HOME/.colima/$COLIMA_VM/docker.sock";
      #DOCKER_HOST="unix://$COLIMA_VM_SOCKET";  
    };
  };

  #   export COLIMA_VM="default"
  # export COLIMA_VM_SOCKET="${HOME}/.colima/${COLIMA_VM}/docker.sock"
  # export DOCKER_HOST="unix://${COLIMA_VM_SOCKET}"

}
