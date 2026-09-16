# List services that you want to enable:
{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.services.amdgpu.enable = lib.mkEnableOption "Set AMD iGPU as primary";

  config = {
    services.dbus.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.videoDrivers = [
      "nvidia"
    ]
    ++ (lib.optionals config.services.amdgpu.enable [ "amdgpu" ]);

    boot = {
      initrd.kernelModules =
        if config.services.amdgpu.enable then
          [
            "amdgpu"
          ]
        else
          [
            "nvidia"
            "nvidia-drm"
            "nvidia-uvm"
            "nvidia-modeset"
          ];
      kernelParams = lib.optionals (!config.services.amdgpu.enable) [ "nvidia-drm.modeset=1" ];
    };

    # Enable the GNOME Desktop Environment.
    # services.displayManager.gdm.enable = true;
    # services.desktopManager.gnome.enable = true;

    # Enable the KDE Desktop Environment.
    # services.displayManager.defaultSession = "plasmax11";
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = lib.mkDefault false;
      # This option causes SDDM's splash screen not to show up.
      # settings.General.DisplayServer = "x11-user";
    };
    services.desktopManager.plasma6.enable = true;
    services.aero = {
      enable = true;
      plymouth.enable = true;
    };

    # Configure keymap in X11
    # services.xserver.xkb.layout = "us";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";

    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable sound.
    # hardware.pulseaudio.enable = true;
    # OR
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    services.btrfs.autoScrub.enable = true;
    services.btrfs.autoScrub.interval = "weekly";
    services.btrfs.autoScrub.fileSystems = [ "/" ];

    # Enable touchpad support (enabled default in most desktopManager).
    # services.libinput.enable = true;

    services.cloudflare-warp.enable = true;

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "blisk" ];
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';
    };

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    hardware.nvidia = lib.mkIf config.services.amdgpu.enable {
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
      };
    };
  };
}
