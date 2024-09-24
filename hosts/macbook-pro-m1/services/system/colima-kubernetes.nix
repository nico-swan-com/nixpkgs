{ configVars, ...}:
{
  imports = [
     #../modules/kubernetes/colima-kubernetes.nix
  ];

  # #Kubernetter-cluster
  # services.colima-kubernetes = {
  #    enable = true;
  #    memory = 8;
  #    cpu = 4;
  #    disk = 10;
  #    runAs = "${configVars.username}";
  # };
}