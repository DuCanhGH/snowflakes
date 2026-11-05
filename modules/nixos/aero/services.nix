{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  plymouth-vista = pkgs.callPackage ./misc/plymouth.nix {
    inherit (pkgs) aero;
  };
  cfg = config.services.aero;
in
{
  options.services.aero = {
    enable = lib.mkEnableOption "Enable Aero";
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
    boot = {
      plymouth = lib.mkIf cfg.plymouth.enable {
        theme = "plymouth-vista";
        themePackages = [
          plymouth-vista
        ];
        font = "${pkgs.aero.fonts}/share/fonts/truetype/segoeui.ttf";
      };
      initrd.systemd.contents."/etc/plymouth/fonts".source = lib.mkForce (
        pkgs.runCommand "plymouth-fonts" { } ''
          mkdir -p $out
          cp ${pkgs.aero.fonts}/share/fonts/truetype/segoeui.ttf ${pkgs.aero.fonts}/share/fonts/truetype/seguisym.ttf $out/
        ''
      );
    };

    systemd.services.plymouth-quit.serviceConfig = lib.mkIf (cfg.plymouth.delay != null) {
      ExecStartPre = [ "${pkgs.coreutils}/bin/sleep ${lib.toString cfg.plymouth.delay}" ];
    };

    environment.sessionVariables = {
      QML_DISABLE_DISTANCEFIELD = "1";
    };

    environment.systemPackages =
      (with pkgs.aero; [
        aerothemeplasma
        fonts
        icons
        sounds
        components
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
      wayland.enable = true;
      theme = "sddm-theme-mod";
      settings = {
        General = {
          DisplayServer = "wayland";
        };
        Theme = {
          CursorTheme = "aero-drop";
        };
      };
    };

    services.displayManager.defaultSession = "aerothemeplasma";

    services.displayManager.sessionPackages = with pkgs; [
      aero.aerothemeplasma
    ];

    systemd.packages = with pkgs; [
      aero.uac-polkit-agent
    ];

    fonts.packages = with pkgs; [
      corefonts
      aero.fonts
      vista-fonts
    ];
  };
}
