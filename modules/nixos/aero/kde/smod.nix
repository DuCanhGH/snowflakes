{
  pkgs,
  lib,
  mkAeroDerivation,
  aero,
}:
mkAeroDerivation {
  pname = "aero-smod";
  src = pkgs.repos.aero-smod;
  buildInputs = with pkgs.kdePackages; [
    kirigami
    kcoreaddons
    kcolorscheme
    kguiaddons
    ki18n
    kiconthemes
    kwindowsystem
    kdecoration
    kcmutils
  ];
  cmakeFlags = [
    (lib.cmakeBool "BUILD_EFFECT" false)
    (lib.cmakeBool "BUILD_EFFECTX11" false)
    (lib.cmakeBool "BUILD_DECORATION" true)
  ];
}
