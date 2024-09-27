{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.colima;

  mkBoolOption = description: default: mkOption {
    inherit description;
    type = types.bool;
    inherit default;
  };

  mkStrOption = description: default: mkOption {
    inherit description;
    type = types.str;
    inherit default;
  };

  mkListStrOption = description: default: mkOption {
    inherit description;
    type = types.listOf types.str;
    inherit default;
  };

  mkAttrsOption = description: default: mkOption {
    inherit description;
    type = types.attrsOf types.attrs;
    inherit default;
  };

  networkType = lib.types.submodule {
    options = {
      address = mkBoolOption "Assign reachable IP address to the VM" true;
      dns = mkListStrOption "The DNS servers to use." [ "8.8.8.8" "1.1.1.1" ];
      dnsHosts = mkAttrsOption "DNS hostnames to resolve to custom targets using the internal resolver." { };
    };
  };

  kubernetesType = lib.types.submodule {
    options = {
      enabled = mkBoolOption "Enable kubernetes" false;
      version = mkStrOption "Kubernetes version to use." "v1.30.0+k3s1";
      k3sArgs = mkListStrOption "Additional args to pass to k3s." [ ];
      kubernetesDisable = mkListStrOption "The kubernetes components to disable." [ ];
    };
  };

  launchdType = lib.types.submodule {
    options = {
      enable = mkBoolOption "Enable starting as launchd service." false;
      labelPrefix = mkStrOption "The launchd label." "colima";
    };
  };


  vmConfigType = lib.types.submodule {
    options = {
      hostname = mkStrOption "The hostname of the colima instance." "default";
      enable = mkBoolOption "Enable the VM" true;
      cpu = mkOption {
        description = "The number of CPUs to allocate.";
        type = types.nullOr types.int;
        example = 4;
        default = 2;
      };
      memory = mkOption {
        description = "The amount of memory to allocate.";
        type = types.nullOr types.int;
        example = 8;
        default = 2;
      };
      disk = mkOption {
        description = "The amount of disk space to allocate.";
        type = types.nullOr types.int;
        example = 1;
        default = 60;
      };
      arch = mkOption {
        description = "The architecture to use.";
        type = types.enum [ "x86_64" "aarch64" ];
        default = "aarch64";
      };
      runtime = mkOption {
        description = "The container runtime to use. default is docker";
        type = types.enum [ "containerd" "docker" ];
        example = "containerd";
        default = "docker";
      };
      autoActivate = mkBoolOption "Auto-activate on the Host for client access." true;
      kubernetes = mkOption {
        description = "Kubernetes configuration for the virtual machine.";
        type = kubernetesType;
        default = { };
      };
      network = mkOption {
        description = "Network configurations for the virtual machine.";
        type = networkType;
        default = { };
      };
      forwardAgent = mkBoolOption "Forward the host's SSH agent to the virtual machine." false;
      docker = mkAttrsOption "Docker daemon configuration that maps directly to daemon.json." { };
      vmType = mkStrOption "Virtual Machine type (qemu, vz)" "qemu";
      rosetta = mkBoolOption "Utilise rosetta for amd64 emulation (requires m1 mac and vmType `vz`)" false;
      mountType = mkStrOption "Volume mount driver for the virtual machine (virtiofs, 9p, sshfs)." "sshfs";
      mountInotify = mkBoolOption "Propagate inotify file events to the VM." false;
      cpuType = mkStrOption "The CPU type for the virtual machine (requires vmType `qemu`)." "host";
      provision = mkOption {
        description = "Custom provision scripts for the virtual machine.";
        type = types.listOf (types.attrsOf types.attrs);
        default = [ ];
      };
      sshConfig = mkBoolOption "Modify ~/.ssh/config automatically to include a SSH config for the virtual machine." true;
      mounts = mkOption {
        description = "Configure volume mounts for the virtual machine.";
        type = types.listOf (types.attrsOf types.attrs);
        default = [ ];
      };
      env = mkAttrsOption "Environment variables for the virtual machine." { };
      launchd = mkOption {
        description = "Launchd configuration for the virtual machine.";
        type = launchdType;
        default = { };
      };
    };
  };

  generateConfigFile = vm: pkgs.runCommand "${vm.hostname}.yaml" { } ''
    echo ${builtins.toJSON vm} | ${pkgs.remarshal}/bin/json2yaml -o $out
  '';

  configJSON = vm: pkgs.writeText "${vm.hostname}.json" (builtins.toJSON vm);
  configFile = vm: pkgs.runCommand "${vm.hostname}.yaml" { } ''
    ${pkgs.remarshal}/bin/json2yaml -i ${configJSON vm} -o $out
  '';

in
{
  options.services.colima = {
    enable = mkEnableOption "Colima with VMs";
    vms = mkOption {
      description = "VM configurations.";
      type = types.listOf vmConfigType;
    };
  };

  config =
    let
      kubernetesEnable = vm: lib.optionalString (vm.kubernetes.enabled == true) " --kubernetes=true";
      kubernetesVersion = vm: lib.optionalString (vm.kubernetes.version != null) " --kubernetes-version=${vm.kubernetes.version}";
      k3sArgsOptions = vm: "[${lib.concatStringsSep " " (builtins.map (config: "${config}") vm.kubernetes.k3sArgs)}]";
      k3sArgs = vm: lib.optionalString ((k3sArgsOptions vm) != "[]") " --k3s-arg=${kubernetesDisableOptions vm}";
      kubernetesDisableOptions = vm: "${lib.concatStringsSep "," (builtins.map (config: "${config}") vm.kubernetes.kubernetesDisable)}";
      kubernetesDisable = vm: lib.optionalString ((kubernetesDisableOptions vm) != "") " --kubernetes-disable=\"${kubernetesDisableOptions vm}\"";
      kubernetes = vm: "${kubernetesEnable vm}${kubernetesVersion vm}${k3sArgs vm}${kubernetesDisable vm}";

      cpu = vm: lib.optionalString (vm.cpu != null) " --cpu=${toString vm.cpu}";
      memory = vm: lib.optionalString (vm.memory != null) " --memory=${toString vm.memory}";
      disk = vm: lib.optionalString (vm.disk != null) " --disk=${toString vm.disk}";
      arch = vm: lib.optionalString (vm.arch != null) " --arch=${vm.arch}";
      hardware = vm: "${cpu vm}${memory vm}${disk vm}${arch vm}";

      networkAddress = vm: lib.optionalString (vm.network.address == true) " --network-address=true";
      hostname = vm: lib.optionalString (vm.hostname != null) " --hostname=${vm.hostname}";
      dns = vm: " ${lib.concatStringsSep " " (builtins.map (ip: "--dns=${ip}") vm.network.dns)}";
      network = vm: "${hostname vm}${networkAddress vm}${dns vm}";

      startScript = vm: pkgs.writeScriptBin "start-${vm.launchd.labelPrefix}-${vm.hostname}.sh" ''
        export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/run/current-system/sw/bin"
          
        KUBERNETES="${kubernetes vm}"
        NETWORK="${network vm}" 
        HARDWARE="${hardware vm}"

        ${pkgs.colima}/bin/colima start -p ${vm.hostname} $KUBERNETES $NETWORK $HARDWARE --very-verbose
      '';

      launchdScript = vm: pkgs.writeScriptBin "launchd-${vm.launchd.labelPrefix}-${vm.hostname}.sh" ''
        YAML_FILE="${config.home.homeDirectory}/.config/colima/${vm.launchd.labelPrefix}-${vm.hostname}-service.yaml"

        # Check if the YAML file exists, create it if it doesn't
        if [ ! -f "$YAML_FILE" ]; then
          echo "YAML file does not exist. Creating it..."
          mkdir -p ${config.home.homeDirectory}/.config/colima/
          echo -e "service:\n  state: start" > "$YAML_FILE"
        fi


        # Function to start Colima instance
        start_colima() {
            #if ! ${pkgs.colima}/bin/colima status | grep - q "Running"; then
                echo "Starting Colima instance..."
                ${startScript vm}/bin/start-${vm.launchd.labelPrefix}-${vm.hostname}.sh
            #fi
        }

        # Function to stop Colima instance
        stop_colima() {
            #if ${pkgs.colima}/bin/colima status | grep - q "Running"; then
              echo "Stopping Colima instance..."
              ${pkgs.colima}/bin/colima stop ${vm.hostname}
              if [ $? -eq 0 ]; then
                  echo "Colima instance ${vm.hostname} stopped successfully."
              fi
            #fi
        }

        # Function to check the service state from the YAML file
        check_service_state() {
            local state
            state=$(${pkgs.yq}/bin/yq -e '.service.state' "$YAML_FILE")
            echo "Service state: $state"
            if [ "$state" == "start" ]; then
                start_colima
            elif [ "$state" == "stop" ]; then
                stop_colima
            fi
        }

        # Monitor the file for changes using fswatch
        fswatch -o "$YAML_FILE" |
        while read -r event; do
            check_service_state
        done

        # Trap the stop signal to stop Colima instance when the agent is stopped or disabled
        trap stop_colima SIGTERM

        # Keep the script running
        while true; do
            sleep 1
        done


      '';

    in
    mkIf cfg.enable {

      home.packages = with pkgs; mkIf (cfg.vms != [ ]) [
        colima
        fswatch
      ];


      programs.zsh = {
        shellAliases = lib.mkMerge (map
          (vm: {
            "kube-colima-${vm.hostname}-context" = "kubectl config use-context colima-${vm.hostname}";
          })
          cfg.vms);

        initExtra = lib.mkMerge (map
          (vm: ''
            start-colima-${vm.hostname}() {
              ${pkgs.bash}/bin/bash -l -c ${startScript vm}/bin/start-${vm.launchd.labelPrefix}-${vm.hostname}.sh
            }
          '')
          cfg.vms);
      };

      launchd = {
        enable = true;
        agents = lib.mkMerge (map
          (vm: {
            "${vm.launchd.labelPrefix}-${vm.hostname}" = {
              enable = vm.launchd.enable;
              config = {
                ProgramArguments = [
                  "${pkgs.bash}/bin/bash"
                  "-l"
                  "-c"
                  "${launchdScript vm}/bin/launchd-${vm.launchd.labelPrefix}-${vm.hostname}.sh"
                ];
                Label = "${vm.launchd.labelPrefix}-${vm.hostname}";
                LaunchOnlyOnce = true;
                StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${vm.launchd.labelPrefix}-${vm.hostname}.stderr.log";
                StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${vm.launchd.labelPrefix}-${vm.hostname}.stdout.log";
                RunAtLoad = true;
                KeepAlive = false;
                EnableTransactions = true;
              };
            };
          })
          cfg.vms);
      };
    };
}
