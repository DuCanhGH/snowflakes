{
  pkgs,
  lib,
  mkAeroDerivation,
  smod,
}:
mkAeroDerivation {
  pname = "aero-smodglow";
  buildInputs = [
    smod
  ];
  src = pkgs.repos.aero-smod;
  cmakeFlags = [
    (lib.cmakeBool "BUILD_EFFECT" true)
    (lib.cmakeBool "BUILD_DECORATION" false)
  ];
}
