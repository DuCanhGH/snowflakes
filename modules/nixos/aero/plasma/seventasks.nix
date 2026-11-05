{ mkAeroDerivation, aero }:

mkAeroDerivation {
  pname = "aero-seventasks";
  src = aero.dev;
  ninjaFlags = [ "io.gitgud.wackyideas.seventasks" ];
  installTargets = "plasma/plasmoids/src/seventasks_src/install";
}
