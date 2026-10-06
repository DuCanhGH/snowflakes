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
  llama-cpp = pkgs.llama-cpp.override { cudaSupport = true; };
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
    loader.systemd-boot.xbootldrMountPoint = "/boot";
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/efi";
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  fileSystems = {
    "/efi/EFI/Linux" = {
      device = "/boot/EFI/Linux";
      fsType = "vfat";
      options = [ "bind" ];
    };
    "/efi/EFI/nixos" = {
      device = "/boot/EFI/nixos";
      fsType = "vfat";
      options = [ "bind" ];
    };
    "/swap".options = [ "noatime" ];
  };

  networking.hostName = "pneuma"; # Define your hostname.

  environment.systemPackages = [ llama-cpp ];

  services.aero = {
    wayland.enable = true;
    plymouth.delay = 5;
    video-wallpaper.enable = true;
  };

  services.asusd.enable = true;

  services.amdgpu.enable = true;

  services.cardwired = {
    enable = true;
    settings = {
      battery_auto_switch = true;
      battery_auto_switch_mode = "integrated";
      external_display_auto_switch = true;
    };
  };

  services.llama-cpp = {
    enable = true;
    package = llama-cpp;
    settings.models-preset =
      (pkgs.formats.ini { }).generate "models-preset.ini"
        llama-models.models-preset;
  };

  home-manager.users.ducanh = {
    programs.pi-coding-agent = with llama-models; {
      enable = true;
      models.providers."llama.cpp".models = mkPiModels {
        "Qwen/Qwen3.6-35B-A3B" = qwen-pi-params // {
          name = "Qwen3.6-35B-A3B (local)";
        };
      };
    };
  };

  hardware.bluetooth.enable = true;

  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:0@65:00:0";
    nvidiaBusId = "PCI:0@01:0:0";
  };
}
