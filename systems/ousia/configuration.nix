# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  config,
  lib,
  homa,
  ...
}:
let
  llama-cpp =
    (pkgs.llama-cpp.override {
      cudaSupport = true;
      rocmSupport = true;
      blasSupport = true;
    }).overrideAttrs
      (oldAttrs: rec {
        version = "10970";
        src = pkgs.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          tag = "b${version}";
          hash = "sha256-MvDdikCCCPAJYF06wu4yiQO/ji61BxRGghBjLubk4E0=";
          leaveDotGit = true;
          postFetch = ''
            git -C "$out" rev-parse --short HEAD > $out/COMMIT
            find "$out" -name .git -print0 | xargs -0 rm -rf
          '';
        };
        npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
        cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
          "-DGGML_NATIVE=ON"
        ];
        preConfigure = ''
          export NIX_ENFORCE_NO_NATIVE=0
          ${oldAttrs.preConfigure or ""}
        '';
      });
  qwen-27b-ud-q6_k = pkgs.homa.fetchFromHuggingFace {
    repo = "unsloth/Qwen3.8-27B-GGUF";
    file = "Qwen3.8-27B-UD-Q6_K.gguf";
    version = "4ca720788d1e01f1bff70c033e0d0028fd02e502";
    hash = "sha256-ycIGgS++Sse3anKeJZKLY/KuidN/adp6ccIK7HY81DY=";
  };
  qwen-thinking-params = {
    flash-attn = "on";
    temp = 1.0;
    top-p = 0.95;
    top-k = 20;
    min-p = 0.0;
    presence-penalty = 0.0;
    repeat-penalty = 1.0;
    reasoning-preserve = true;
  };
  qwen-27b-params = qwen-thinking-params // {
    mmproj = pkgs.homa.fetchFromHuggingFace {
      repo = "unsloth/Qwen3.8-27B-GGUF";
      file = "mmproj-BF16.gguf";
      version = "4ca720788d1e01f1bff70c033e0d0028fd02e502";
      hash = "sha256-g+5PTyBfpRQWF3jEHfHqFBRPqg9xNRCJO2PCOV9cLVM=";
    };
    ag = true;
    dev = "ROCm0,CUDA0";
    ts = "2.5,1";
    jinja = true;
    ngl = 999;
    np = 4;
    kvu = true;
    spec-type = "draft-mtp,ngram-mod";
    spec-draft-n-max = 2;
    threads = 12;
    batch-size = 2048;
    ubatch-size = 512;
    image-min-tokens = 1024;
  };
  qwen-opencode-config = {
    modalities = {
      input = [
        "text"
        "audio"
        "image"
        "video"
        "pdf"
      ];
    };
    options = {
      reasoningEffort = "xhigh";
      textVerbosity = "low";
      reasoningSummary = "auto";
    };
    variants = {
      medium = {
        reasoningEffort = "medium";
        textVerbosity = "low";
        reasoningSummary = "auto";
      };
      low = {
        reasoningEffort = "low";
        textVerbosity = "low";
        reasoningSummary = "auto";
      };
    };
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

  programs.ccache.packageNames = [ "llama-cpp" ];

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
    settings.models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" {
      "Qwen/Qwen3.8-27B" = qwen-27b-params // {
        m = qwen-27b-ud-q6_k;
        c = 169216;
        ctk = "bf16";
        ctv = "bf16";
        no-mmproj-offload = true;
      };
      "Qwen/Qwen3.8-27B-Vision" = qwen-27b-params // {
        m = qwen-27b-ud-q6_k;
        c = 131072;
        ctk = "bf16";
        ctv = "bf16";
      };
    };
  };

  services.udev.extraHwdb = ''
    evdev:input:b0003v25A7p2301e0110*
      KEYBOARD_KEY_700e3=space
  '';

  home-manager.users.ducanh = {
    programs.opencode = {
      enable = true;
      settings.provider."llama.cpp".models = {
        "Qwen/Qwen3.8-27B" = qwen-opencode-config // {
          name = "Qwen3.8-27B (local, Q6_K)";
          limit = {
            context = 169216;
            output = 65536;
          };
        };
        "Qwen/Qwen3.8-27B-Vision" = qwen-opencode-config // {
          name = "Qwen3.8-27B (local, Q6_K, offloaded vision)";
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
    nvidiaBusId = "PCI:1@0:0:0";
    amdgpuBusId = "PCI:13@0:0:0";
  };
}
