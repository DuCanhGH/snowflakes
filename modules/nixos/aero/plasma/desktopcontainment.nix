{
  pkgs,
  lib,
  mkAeroDerivation,
  aero,
}:

mkAeroDerivation {
  pname = "aero-desktopcontainment";
  src = aero.dev;
  ninjaFlags = [ "folderplugin" ];
  installTargets = "plasma/plasmoids/src/desktopcontainment/install";
}
