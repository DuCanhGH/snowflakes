{
  pkgs,
  mkAeroDerivation,
  aero,
}:

mkAeroDerivation {
  pname = "aero-systemtray";
  src = aero.dev;
  ninjaFlags = [ "io.gitgud.wackyideas.systemtray" ];
  installTargets = "plasma/plasmoids/src/systemtray_src/install";
}
