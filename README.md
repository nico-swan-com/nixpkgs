# Nico Swan packages
Here we have a collection of nix packages and configuration that are used in my environments. 

# Usage of this project
To apply this to you nix config see the example configuration [ see example project](./example-configuration/) 
For a full list of instruction on preparing environment see the boilerplate projects 
* [nix-secrets](https://github.com/nico-swan-com/nix-secrets) - Private Repo - A project to keep your password, access keys etc in a single place and encrypted using sops.
* [nix-config](https://github.com/nico-swan-com/nix-config) - An expanded version of the example with integrated secrets and additional configuration for developers.

```
#example flake.nix 
{
  description = "Example flake to apply nicoswan nixpkgs";
  inputs = {
    # Add nicoswan packages and modules 
    nicoswan.url = "github:nico-swan-com/nixpkgs?ref=main&shallow=1";
    
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , nicoswan
    , ...
    } @inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      mkSystem = nicoswan.mkSystem {
        inherit nixpkgs outputs inputs lib nix-darwin home-manager;
      };
    in
    {
      darwinConfigurations.darwin = mkSystem "darwin" {
        system = "aarch64-darwin";
        username = "nicoswan";
        fullname = "Nico Swan";
        email = "hi@nicoswan.com";
        locale = "en_ZA.UTF-8";
        timezone = "Africa/Johannesburg";
        darwin = true;
        extraModules = [ ./configuration.nix ];
        extraHMModules = [ ./home.nix ];
      };
    };
}

```
# What is provided
There are many default configuration and a packages installed to assets with any developer flow

## Core Packages 
See [core-configuration.nix](modules/core-configuration.nix) and  [home-manager default](home-manager/default.nix) 

### Programs
* zsh
* git - git cli and configuration
* vim - vi editor
* sops - to encrypt and decrypt secrets
* just - a command runner and a handy way to save and run project-specific commands.
* direnv - is an extension for your shell. It augments existing shells with a new feature that can load and unload environment variables depending on the current directory.
* lazygit - git TUI
* nnn - Terminal file manager 

### Archives
* zip - zip archiver
* unzip - unzip archiver
* p7zip - zip archiver and compressor
* xz - compressor

### Utils and command replacements
* ripgrep - Recursively searches directories for a regex pattern and internal 
* jq -  A lightweight and flexible command-line JSON processor
* yq-go - yaml processor see [repo](https://github.com/mikefarah/yq)
* eza - A modern replacement for ‘ls’
* fzf - A command-line fuzzy finder
* bat - a cat replacement
* tldr - man page replacement
* dust - Disk utilization tool
* btop - Replacement of htop/nmon
* iftop - Network monitoring
* lsof - List open files and sockets
* fswatch - Watch file system events
* git-extras - Some git extra command see [repo](https://github.com/tj/git-extras)
* terminal-notifier - send macOS User Notifications from the command line

### Developer tools
#### Google Cloud SDK
See [programs.nicoswan.utils.google-cloud-sdk](./modules/home-manager/utils/google-cloud.nix)
* gcloud - Google Cloud SDK
* gke-gcloud-auth-plugin
* cloud_sql_proxy
* pubsub-emulator

#### Kubernetes
* kubectl - Kubernetes CLI

## Additional optional packages
The following packages are installed when a user enables the packages
### Kubernetes 
See [programs.nicoswan.utils.kubernetes](modules/home-manager/utils/kubernetes.nix)
#### Additional utils
Set `programs.nicoswan.utils.kubernetes.additional-utils = true;` to enable the following
* kubectx - Switch between kubernetes contexts
* kns - Switch between kubernetes namespaces
* kail - Kubernetes log viewer
* ktop - Top like interface for kubernetes clusters
* k9s - Kubernetes TUI to manage your cluster in a terminal
#### Admin utils
Set `programs.nicoswan.utils.kubernetes.admin-utils = true;` to enable the following
* helm - Helm is the package manager for Kubernetes. It allows you to define and install packages of pre-configured Kubernetes resources.
* helmfile - A tool that helps you manage complex deployments with Helm.

## Optional programs and packages
### Networking
See [programs.nicoswan.utils.networking](modules/common/utils/networking.nix)

## Configuration
There are some boilerplate configuration for your system that could be overridden by the user but should give you a good start.
### ZSH
see [programs.nicoswan.zsh](./modules/home-manager/programs/zsh.nix)
* Completion
* Autosuggestions
* history substring search
* syntax highlighting
#### Core shell aliases
* la - `eza  --long -a --group-directories-first --icons=always --color=auto --almost-all --time-style=long-iso`
* ll - `la --long --no-user --no-time --no-permissions --no-filesize`
* cat - `bat -p`
* grep = `grep --color=auto`
* egrep = `egrep --color=auto`
* fgrep = `fgrep --color=auto`
#### Kubernetes shell aliases
See [programs.nicoswan.utils.kubernetes](modules/home-manager/utils/kubernetes.nix)
* ksandbox-context - set use context to sandbox
* ksandbox - kubectl to sandbox context and sandbox namespace

#### Google cloud shell aliases
See [programs.nicoswan.utils.google-cloud](modules/home-manager/utils/google-cloud.nix)
* db-open-prod = `cloud_sql_proxy -enable_iam_login -instances=nicoswan-group:europe-west2:nicoswan-production=tcp:3307,nicoswan-group:europe-west2:nicoswan-pg1=tcp:15432`
* db-open-sandbox - `cloud_sql_proxy -enable_iam_login -instances=nicoswan-group-sandbox:europe-west2:nicoswan-pg1=tcp:15432,nicoswan-group-sandbox:europe-west2:sandbox=tcp:3307`


### Git
See [home-manager default](home-manager/default.nix) 
### starship
See [starship](./modules/home-manager/programs/starship.nix) 

### MacOS
* enabled apple virtualization
* screencapture.location = `$HOME/Documents/Captures`

#### Finder
* AppleShowAllFiles = true;
* AppleShowAllExtensions = true;
* QuitMenuItem = true;
* FXEnableExtensionChangeWarning = false;

## Databases
### Postgres
See [services.nicoswan.postgres](modules/common/databases/postgres.nix)
This will create a database with your user with a default password of 'password'
