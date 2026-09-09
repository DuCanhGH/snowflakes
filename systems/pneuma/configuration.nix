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
  qwen-thinking-params = {
    flash-attn = "on";
    temp = 0.6;
    top-p = 0.95;
    top-k = 20;
    min-p = 0.0;
    presence-penalty = 0.0;
    repeat-penalty = 1.0;
  };
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

  services.supergfxd.enable = true;

  services.amdgpu.enable = true;

  services.llama-cpp = {
    enable = true;
    package = llama-cpp;
    settings.models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" {
      "Qwen/Qwen3.6-35B-A3B" = qwen-thinking-params // {
        m = pkgs.homa.fetchFromHuggingFace {
          repo = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
          file = "Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf";
          version = "5bc3e238d916f48a861bac2f8a1990a0e9b7e98d";
          hash = "sha256-NvnsDkx3X279OmHB6nbwh1EoRpw9AS49niSVqQ56cVA=";
        };
        jinja = true;
        c = 131072;
        np = 1;
        n-cpu-moe = 26;
        kvu = true;
        ctk = "q8_0";
        ctv = "q8_0";
        threads = 6;
        threads-batch = 12;
        batch-size = 2048;
        ubatch-size = 512;
        image-min-tokens = 1024;
      };
    };
  };

  home-manager.users.ducanh = {
    programs.opencode = {
      enable = true;
      settings.provider."llama.cpp".models = {
        "Qwen/Qwen3.6-35B-A3B" = {
          name = "Qwen3.6-35B-A3B (local)";
          limit = {
            context = 131072;
            output = 65536;
          };
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
