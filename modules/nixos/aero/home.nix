{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.aero.enable = lib.mkEnableOption "Enable Aero user configuration";
  config = lib.mkIf config.aero.enable {
    home.packages = with pkgs; [
      aero.aerothemeplasma
    ];
    home.file = {
      ".local/share/smod".source = "${pkgs.aero.kwin}/share/smod";
      ".config/Kvantum".source = "${pkgs.aero.aerothemeplasma}/share/Kvantum";
    };
    fonts.fontconfig = {
      enable = true;
      hinting = "full";
      defaultFonts = {
        sansSerif = [ "Segoe UI" ];
        serif = [ "Segoe UI" ];
        monospace = [ "Hack" ];
      };
    };
    programs.plasma = {
      enable = true;
      shortcuts.kwin = {
        "MinimizeAll" = "Meta+D";
        "Peek at Desktop" = [ ];
        "Walk Through Windows Alternative" = "Meta+Tab";
      };
      configFile = {
        "kwinrc"."MouseBindings" = {
          "CommandAll1" = "Activate, raise and move";
          "CommandWheel" = "Nothing";
          "CommandTitlebarWheel" = "Nothing";
        };
        "kwinrc"."Outline"."QmlPath" = "aeroshell/outline/plasma/outline.qml";
        "kwinrc"."Plugins" = {
          "aeroglassblurEnabled" = true;
          "aeroglideEnabled" = true;
          "backgroundcontrastEnabled" = false;
          "blurEnabled" = false;
          "desaturateUnresponsiveAppsEnabled" = true;
          "dialogparentEnabled" = false;
          "dimScreenForAdminModeEnabled" = true;
          "diminactiveEnabled" = false;
          "dimscreenEnabled" = false;
          "dimscreenaeroEnabled" = true;
          "fadingPopupsEnabled" = true;
          "fadingpopupsEnabled" = false;
          "libkwin_effect_smodsnapEnabled" = true;
          "loginEnabled" = false;
          "logoutEnabled" = false;
          "maximizeEnabled" = false;
          "minimizeallEnabled" = true;
          "scaleEnabled" = false;
          "slideEnabled" = false;
          "slidingnotificationsEnabled" = false;
          "slidingpopupsEnabled" = false;
          "smodglowEnabled" = true;
          "smodpeekeffectEnabled" = true;
          "smodpeekscriptEnabled" = true;
          "smodsnapEnabled" = true;
          "squashEnabled" = true;
          "startupfeedbackEnabled" = true;
          "windowapertureEnabled" = false;
        };
        "kwinrc"."Scripts" = {
          "minimizeall" = true;
          "smodpeekscript" = true;
        };
        "kwinrc"."TabBox" = {
          "LayoutName" = "thumbnail_aero";
          "ShowDesktopMode" = 1;
        };
        "kwinrc"."TabBoxAlternative" = {
          "LayoutName" = "flip3d";
          "ShowDesktopMode" = 1;
        };
        "kwinrc"."org.kde.kdecoration2" = {
          "ButtonsOnLeft" = "M";
          "ButtonsOnRight" = "H_IAX";
          "library" = "org.smod.smod";
          "theme" = "SMOD";
        };
        "ksmserverrc"."General"."confirmLogout" = false;
        "kcminputrc"."Mouse" = {
          "cursorSize" = 32;
          "cursorTheme" = "aero-drop";
        };
        "klaunchrc" = {
          "FeedbackStyle"."BusyCursor" = false;
          "BusyCursorSettings" = {
            "Bouncing" = false;
            "Blinking" = false;
          };
        };
        "kdeglobals" = {
          "Sounds"."Theme" = "Windows 7";
          "General" = {
            "XftAntialias" = true;
            "XftHintStyle" = "hintslight";
            "XftSubPixel" = "rgb";
            "AccentColor" = "0,0,0,0";
            "accentColorFromWallpaper" = false;
            "ColorScheme" = "Aero";
            "font" = "Segoe UI,9,-1,5,50,0,0,0,0,0";
            "menuFont" = "Segoe UI,9,-1,5,50,0,0,0,0,0";
            "toolBarFont" = "Segoe UI,9,-1,5,50,0,0,0,0,0";
            "smallestReadableFont" = "Segoe UI,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
          };
          "Icons"."Theme" = "Windows 7 Aero";
          "KDE" = {
            "LookAndFeelPackage" = "authui7";
            "widgetStyle" = "kvantum";
          };
          "WM"."activeFont" = "Segoe UI,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        };
      };
      window-rules = [
        {
          description = "POLKIT_RULES";
          match = {
            window-class = {
              value = "(polkit-kde-authentication-agent-1)|(polkit-kde-manager)|(org.kde.polkit-kde-authentication-agent-1)";
              type = "regex";
            };
            machine = {
              value = "localhost";
              type = "exact";
            };
          };
          apply = {
            minimize = {
              value = false;
              apply = "force";
            };
          };
        }
      ];
    };
  };
}
