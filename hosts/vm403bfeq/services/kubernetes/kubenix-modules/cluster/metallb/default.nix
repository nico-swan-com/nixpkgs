{ kubenix, ... }:
  { 
   imports = [ kubenix.modules.helm ];
    # kubernetes.helm.releases.metallb = {
    #   chart = kubenix.lib.helm.fetch {
    #     repo = "metallb";
    #     chart = "metallb/metallb";
    #     version = "0.14.8";
    #     sha256 = "sKVqx99O4SNIq5y8Qo/b/2xIqXqSsZJzrgnYYz/0TKg=";
    #   };
    #   # arbitrary attrset passed as values to the helm release
    #   values.replicaCount = 2;
    #   };
}


# {
#   inputs.kubenix.url = "github:hall/kubenix";
#   outputs = {self, kubenix, ... }@inputs: let
#     system = "x86_64-linux";
#   in {
#     packages.${system}.default = (kubenix.evalModules.${system} {
#       module = { kubenix, ... }: {
#         imports = [ kubenix.modules.k8s ];
#         kubernetes.resources.pods.example.spec.containers.nginx.image = "nginx";
#       };
#     }).config.kubernetes.result;
#   };
# }

# { kubenix ? import ../../../.. }:
# kubenix.evalModules.${builtins.currentSystem} {
#   module = { kubenix, ... }: {
#     imports = [ kubenix.modules.helm ];
#     kubernetes.helm.releases.metallb = {
#       chart = kubenix.lib.helm.fetch {
#         repo = "metallb";
#         chart = "metallb/metallb";
#         version = "0.14.8";
#         sha256 = "sKVqx99O4SNIq5y8Qo/b/2xIqXqSsZJzrgnYYz/0TKg=";
#       };
#       # arbitrary attrset passed as values to the helm release
#       values.replicaCount = 2;
#     };
#   };
# }


# repositories:
#   # Load Balancers
#   - name: metallb 
#     url: https://metallb.github.io/metallb

# releases: 
#   - name: metallb
#     namespace: metallb-system
#     chart: metallb/metallb
#     version: 0.14.8
#     atomic: true
#     timeout: 300
#     labels:
#       app: metallb
#       tier: infrastructure
#     hooks:
#     #--This hook ensures that the MetalLB address pool
#     #--is defined after helm has synced the release
#     - events: ["cleanup"]
#       showlogs: true
#       command: kubectl
#       args: 
#         - apply
#         - -f
#         - metallb-pool.yaml
