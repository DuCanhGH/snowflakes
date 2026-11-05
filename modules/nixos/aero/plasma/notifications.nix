{
  pkgs,
  mkAeroDerivation,
  aero,
}:

mkAeroDerivation {
  pname = "aero-notifications";
  src = aero.dev;
  ninjaFlags = [ "io.gitgud.wackyideas.notifications" ];
  installTargets = "plasma/plasmoids/src/notifications_src/install";
}
