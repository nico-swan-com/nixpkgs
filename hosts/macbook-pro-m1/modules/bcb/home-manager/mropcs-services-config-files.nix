{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.bcb.process-manager;

  # procs: object - Processes to run.Only allowed in local config.
  #   shell: string - Shell command to run (exactly one of shell or cmd must be provided).
  #   cmd: array - Array of command and args to run (exactly one of shell or cmd must be provided).
  #   cwd: string - Set working directory for the process. Prefix <CONFIG_DIR> will be replaced with the path of the directory where the config is located.
  #   env: object<string, string|null> - Set env variables. Object keys are variable names. Assign variable to null, to clear variables inherited from parent process.
  #   add_path: string|array - Add entries to the PATH environment variable.
  #   autostart: bool - Start process when mprocs starts. Default: true.
  #   autorestart: bool - Restart process when it exits. Default: false. Note: If process exits within 1 second of starting, it will not be restarted.
  #   stop: "SIGINT"|"SIGTERM"|"SIGKILL"|{send-keys: array}|"hard-kill" - A way to stop a process (using x key or when quitting mprocs).
  # hide_keymap_window: bool - Hide the pane at the bottom of the screen showing key bindings.
  # mouse_scroll_speed: integer - Number of lines to scrollper one mouse scroll.
  # scrollback: integer - Scrollback size. Default: 1000.
  # proc_list_width: integer - Process list window width.
  # keymap_procs: object - Key bindings for process list. See Keymap.
  # keymap_term: object - Key bindings for terminal window. See Keymap.
  # keymap_copy: object - Key bindings for copy mode. See Keymap.


  proccessType = lib.types.submodule {
    options = {

      name = mkOption {
        description = "The name of the process.";
        type = types.str;
      };

      shell = mkOption {
        description = "Shell command to run (exactly one of shell or cmd must be provided).";
        type = types.nullOr types.str;
        default = null;
      };

      cmd = mkOption {
        description = "Array of command and args to run (exactly one of shell or cmd must be provided).";
        type = types.nullOr (types.listOf types.str);
        default = null;
      };

      cwd = mkOption {
        description = "Set working directory for the process. Prefix <CONFIG_DIR> will be replaced with the path of the directory where the config is located.";
        type = types.nullOr types.str;
        default = null;
      };

      env = mkOption {
        description = "Set env variables. Object keys are variable names. Assign variable to null, to clear variables inherited from parent process.";
        type = types.nullOr (types.attrsOf types.envVar);
        default = null;
      };

      add_path = mkOption {
        description = "Add entries to the PATH environment variable.";
        type = types.nullOr (types.listOf types.str);
        default = null;
      };

      autostart = mkOption {
        description = "Start process when mprocs starts.";
        type = types.bool;
        default = true;
      };

      autorestart = mkOption {
        description = "Restart process when it exits.";
        type = types.bool;
        default = false;
      };

      stop = mkOption {
        description = "A way to stop a process (using x key or when quitting mprocs).";
        type = types.enum [ "SIGINT" "SIGTERM" "SIGKILL" "hard-kill" ];
        default = "SIGTERM";
      };

    };
  };

  procsJson = proc: (builtins.toJSON proc);

  generateConfigFile = service: pkgs.runCommand "${service.name}.yaml" { } ''
  echo "procs:" > $out
  data='${builtins.toJSON service.procs}'
  echo "$data" | ${pkgs.jq}/bin/jq -c '.[]' | while read -r proc; do
    name=$(echo $proc | ${pkgs.jq}/bin/jq -r '.name')
    autostart=$(echo $proc | ${pkgs.jq}/bin/jq -r '.autostart')
    autorestart=$(echo $proc | ${pkgs.jq}/bin/jq -r '.autorestart')
    shell=$(echo $proc | ${pkgs.jq}/bin/jq -r '.shell // empty')
    cmd=$(echo $proc | ${pkgs.jq}/bin/jq -r '.cmd // empty')
    cwd=$(echo $proc | ${pkgs.jq}/bin/jq -r '.cwd // empty')
    env=$(echo $proc | ${pkgs.jq}/bin/jq -r '.env // empty')

    echo "  $name:" >> $out
    echo "    autostart: $autostart" >> $out
    echo "    autorestart: $autorestart" >> $out
    if [ -n "$shell" ]; then
      echo "    shell: \"$shell\"" >> $out
    fi
    if [ -n "$cmd" ]; then
      echo "    cmd:" >> $out
      echo $cmd | ${pkgs.jq}/bin/jq -r '.[] | "      - \"\(. // empty)\""' >> $out
    fi
    if [ -n "$cwd" ]; then
      echo "    cwd: \"$cwd\"" >> $out
    fi
    if [ -n "$env" ]; then
      echo "    env:" >> $out
      for key in $(echo $env | ${pkgs.jq}/bin/jq -r 'keys[]'); do
        value=$(echo $env | ${pkgs.jq}/bin/jq -r --arg key "$key" '.[$key]')
        if [ "$value" != "null" ]; then
          echo "      $key: \"$value\"" >> $out
        else
          echo "      $key: null" >> $out
        fi
      done
    fi
  done
'';

  servicesType = lib.types.submodule {
    options = {

      name = mkOption {
        description = "The name of the group.";
        type = types.str;
      };

      enable = mkOption {
        description = "Enable the group.";
        type = types.bool;
        default = true;
      };

      procs = mkOption {
        description = "Processes to run.Only allowed in local config.";
        type = types.listOf proccessType;
      };

      hide_keymap_window = mkOption {
        description = "Hide the pane at the bottom of the screen showing key bindings.";
        type = types.bool;
      };

      mouse_scroll_speed = mkOption {
        description = "Number of lines to scrollper one mouse scroll.";
        type = types.int;
      };

      scrollback = mkOption {
        description = "Scrollback size.";
        type = types.int;
      };

      proc_list_width = mkOption {
        description = "Process list window width.";
        type = types.int;
      };

      keymap_procs = mkOption {
        description = "Key bindings for process list. See Keymap.";
        type = types.attrsOf types.str;
      };

      keymap_term = mkOption {
        description = "Key bindings for terminal window. See Keymap.";
        type = types.attrsOf types.str;
      };

      keymap_copy = mkOption {
        description = "Key bindings for copy mode. See Keymap.";
        type = types.attrsOf types.str;
      };

    };
  };

in
{
  options.services.bcb.process-manager = {
    enable = mkEnableOption "Enable bcb services via mprocs.";
    services = mkOption {
      description = "Processes to run.Only allowed in local config.";
      type = types.listOf servicesType;
    };
  };

  config = {
    home.file = lib.mkMerge (map
      (service: mkIf service.enable {
        ".config/bcb/services/${service.name}.yaml".text = builtins.readFile (generateConfigFile service);
      })
      cfg.services);

      programs.zsh = lib.mkMerge (map
        (service: mkIf service.enable { initExtra = ''
        start-${service.name}() {
          mprocs -c ~/.config/bcb/services/${service.name}.yaml
        }
      '';
      }) cfg.services);
  };
}
