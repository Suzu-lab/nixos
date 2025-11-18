# Configuration options for ungoogled-chromium (used as a messaging app instead of Ferdium or other Electron-based solutions)
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}