{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  plymouth-vista = pkgs.callPackage ./misc/plymouth.nix {
    inherit (pkgs.aero) aerofonts;
  };
  cfg = config.services.aero;
in
{
  options.services.aero = {
    enable = lib.mkEnableOption "Enable Aero";
    wayland.enable = lib.mkEnableOption "Enable Wayland";
    video-wallpaper.enable = lib.mkEnableOption "Enable Plasma Video Wallpaper";
    plymouth = {
      enable = lib.mkEnableOption "Enable Plymouth Vista";
      delay = lib.mkOption {
        default = 10;
        description = "Delay before quitting Plymouth";
        type = lib.types.nullOr lib.types.ints.unsigned;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.plymouth = lib.mkIf cfg.plymouth.enable {
      theme = "plymouth-vista";
      themePackages = [
        plymouth-vista
      ];
    };

    systemd.services.plymouth-quit.serviceConfig = lib.mkIf (cfg.plymouth.delay != null) {
      ExecStartPre = [ "${pkgs.coreutils}/bin/sleep ${lib.toString cfg.plymouth.delay}" ];
    };

    environment.sessionVariables = {
      QML_DISABLE_DISTANCEFIELD = "1";
    };

    environment.systemPackages =
      (with pkgs.aero; [
        aerofonts
        aerothemeplasma
        desktopcontainment
        kwin
        libplasma
        libshowdesktop
        libtaskmanager
        notifications
        sevenstart
        seventasks
        smod
        smodglow
        systemtray
        (lib.hiPrio plasmashell)
      ])
      ++ (lib.optionals cfg.video-wallpaper.enable [ pkgs.aero.plasma-video-wallpaper ])
      ++ (with pkgs; [
        kdePackages.qtmultimedia
        kdePackages.qtstyleplugin-kvantum
        kdePackages.sddm-kcm
        kdePackages.kitemmodels
      ]);

    services.displayManager.sddm = {
      wayland.enable = cfg.wayland.enable;
      theme = "sddm-theme-mod";
      settings = {
        General = {
          DisplayServer = lib.mkIf cfg.wayland.enable "wayland";
        };
        Theme = {
          CursorTheme = "aero-drop";
        };
      };
    };

    services.displayManager.defaultSession =
      if cfg.wayland.enable then "aerothemeplasma" else "aerothemeplasmax11";

    services.displayManager.sessionPackages = with pkgs; [
      aero.login-sessions
    ];

    systemd.packages = with pkgs; [
      aero.uac-polkit-agent
    ];

    fonts.packages = with pkgs; [
      corefonts
      vista-fonts
    ];
  };
}
