# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  config,
  lib,
  ...
}:
let
  llama-cpp = pkgs.callPackage ./llama-cpp.nix { inherit config; };
  llama-models = pkgs.callPackage ./llama-models.nix { };
in
{
  imports = [
    ../../modules/nixos
    ./hardware-configuration.nix
  ];

  time.timeZone = "America/Indianapolis";

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    loader.systemd-boot.consoleMode = lib.mkDefault "max";
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  fileSystems = {
    "/swap".options = [ "noatime" ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking.hostName = "ousia"; # Define your hostname.

  environment.systemPackages = (with pkgs; [ rocmPackages.amdsmi ]) ++ [ llama-cpp ];

  programs.davinci.enable = true;

  programs.rstudio.enable = true;

  systemd.services.llama-cpp = {
    environment = {
      ROCR_VISIBLE_DEVICES = "GPU-d2181b1c3446ee4c";
    };
  };

  services.aero.video-wallpaper.enable = true;

  services.amdgpu.enable = true;

  services.llama-cpp = {
    enable = true;
    package = llama-cpp;
    settings.cors-origins = "localhost";
    settings.models-max = 1;
    settings.models-preset =
      (pkgs.formats.ini { }).generate "models-preset.ini"
        llama-models.models-preset;
  };

  services.udev.extraHwdb = ''
    evdev:input:b0003v25A7p2301e0110*
      KEYBOARD_KEY_700e3=space
  '';

  home-manager.users.ducanh = {
    programs.opencode = with llama-models; {
      enable = true;
      settings.provider."llama.cpp".models = mkOpencodeModels {
        "Qwen/Qwen3.8-27B" = qwen-opencode-params // {
          name = "Qwen3.8-27B (local, Q6_K)";
        };
        "Qwen/Qwen3.8-27B-Vision" = qwen-opencode-params // {
          name = "Qwen3.8-27B (local, Q6_K, offloaded vision)";
        };
      };
    };
  };

  hardware.bluetooth.enable = true;

  hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1@0:0:0";
    amdgpuBusId = "PCI:13@0:0:0";
  };
}
