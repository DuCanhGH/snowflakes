{
  pkgs,
  mkAeroDerivation,
  aero,
}:

mkAeroDerivation {
  pname = "aero-sevenstart";
  src = aero.dev;
  ninjaFlags = [ "io.gitgud.wackyideas.SevenStart" ];
  installTargets = "plasma/plasmoids/src/sevenstart_src/install";
}
