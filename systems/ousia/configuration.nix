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

  services.lact = {
    enable = true;
    settings.version = 7;
    settings.daemon = {
      log_level = "info";
      admin_group = "wheel";
      disable_clocks_cleanup = false;
    };
    settings.apply_settings_timer = 5;
    settings.gpus."1002:744C-1002:0E3B-0000:03:00.0" = {
      fan_control_enabled = false;
      pmfw_options.zero_rpm = true;
      performance_level = "auto";
      max_core_clock = 3100;
      max_memory_clock = 1357;
      voltage_offset = -50;
    };
    settings.gpus."10DE:2F04-10DE:205A-0000:0e:00.0" = {
      fan_control_enabled = false;
      power_mizer_mode = "Adaptive";
      gpu_clock_offsets."0" = 300;
      mem_clock_offsets."0" = 1000;
    };
    settings.current_profile = null;
    settings.auto_switch_profiles = false;
  };

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

  hardware.amdgpu.overdrive.enable = true;

  hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1@0:0:0";
    amdgpuBusId = "PCI:13@0:0:0";
  };
}
