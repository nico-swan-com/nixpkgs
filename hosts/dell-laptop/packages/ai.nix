{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    open-interpreter
    ollama
  ];
}
