{
  waylandEnabled ? false,
  pkgs,
  lib,
  ccacheStdenv,
  ...
}:
let
  libplasma = pkgs.callPackage ./kde/libplasma.nix { };
  plasmashell = pkgs.callPackage ./kde/plasmashell.nix {
    inherit libplasma;
  };
  common-cmake-flags = ([
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_KF6=ON"
    "-DPlasma_DIR=${libplasma.dev}/lib/cmake/Plasma"
    "-DPlasmaQuick_DIR=${libplasma.dev}/lib/cmake/PlasmaQuick"
    "-DKPLUGINFACTORY_INCLUDE=${pkgs.kdePackages.kcoreaddons.dev}/include/KF6/KCoreAddons"
    (lib.cmakeBool "KWIN_BUILD_WAYLAND" waylandEnabled)
    (lib.cmakeBool "INSTALL_X11_COMPONENTS" (!waylandEnabled))
  ]);
  # Source: https://github.com/Rotlug/aerothemeplasma-nixos/blob/8452aa903e76f9c20a62024c6d6f2c4be6933c8d/default.nix#L23-L70
  mkAeroDerivation = lib.extendMkDerivation {
    constructDrv = ccacheStdenv.mkDerivation;

    extendDrvArgs =
      final:
      args@{
        pname,
        version ? "0.0.1",
        src,
        cmakeFlags ? [ ],
        nativeBuildInputs ? [ ],
        buildInputs ? [ ],
        ...
      }:
      let
        defaultNative = with pkgs; [
          cmake
          ninja
          pkg-config
          libplasma.dev
          kdePackages.extra-cmake-modules
          kdePackages.wrapQtAppsHook
          kdePackages.kcoreaddons.dev
        ];
        defaultBuild = (
          with pkgs;
          (
            [
              kdePackages.qtbase
              kdePackages.qttools
            ]
            ++ (if waylandEnabled then [ kdePackages.kwin ] else [ kdePackages.kwin-x11 ])
          )
        );
      in
      args
      // {
        inherit pname version src;
        cmakeFlags = common-cmake-flags ++ cmakeFlags;
        nativeBuildInputs = defaultNative ++ nativeBuildInputs;
        buildInputs = defaultBuild ++ buildInputs;
      };
  };
  aero = pkgs.callPackage ./plasma/aerothemeplasma.nix { };
  smod = pkgs.callPackage ./kde/smod.nix {
    inherit mkAeroDerivation aero;
  };
in
{
  inherit smod libplasma plasmashell;
  aerothemeplasma = aero;
  aerofonts = pkgs.callPackage ./misc/aerofonts.nix { };
  desktopcontainment = pkgs.callPackage ./plasma/desktopcontainment.nix {
    inherit mkAeroDerivation aero;
  };
  kcmloader = pkgs.callPackage ./misc/kcmloader.nix {
    inherit mkAeroDerivation aero;
  };
  kwin = pkgs.callPackage ./kde/kwin.nix {
    inherit mkAeroDerivation;
  };
  libshowdesktop = pkgs.callPackage ./kde/libshowdesktop.nix {
    inherit mkAeroDerivation;
  };
  libtaskmanager = pkgs.callPackage ./kde/libtaskmanager.nix {
    inherit mkAeroDerivation;
  };
  login-sessions = pkgs.callPackage ./plasma/login-sessions.nix {
    inherit
      mkAeroDerivation
      aero
      plasmashell
      waylandEnabled
      ;
  };
  notifications = pkgs.callPackage ./plasma/notifications.nix {
    inherit mkAeroDerivation aero;
  };
  plasma-video-wallpaper = pkgs.callPackage ./plasma/plasma-video-wallpaper.nix {
    inherit mkAeroDerivation;
  };
  sevenstart = pkgs.callPackage ./plasma/sevenstart.nix {
    inherit mkAeroDerivation aero;
  };
  seventasks = pkgs.callPackage ./plasma/seventasks.nix {
    inherit mkAeroDerivation aero;
  };
  smodglow = pkgs.callPackage ./kde/smodglow.nix {
    inherit mkAeroDerivation smod waylandEnabled;
  };
  systemtray = pkgs.callPackage ./plasma/systemtray.nix {
    inherit mkAeroDerivation aero;
  };
  uac-polkit-agent = pkgs.callPackage ./kde/uac-polkit-agent.nix {
    inherit mkAeroDerivation;
  };
}
