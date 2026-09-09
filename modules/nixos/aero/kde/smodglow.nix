{
  pkgs,
  lib,
  mkAeroDerivation,
  smod,
  waylandEnabled,
}:
mkAeroDerivation {
  pname = "aero-smodglow";
  buildInputs = [
    smod
  ];
  src = pkgs.repos.aero-smod;
  cmakeFlags = [
    (lib.cmakeBool "BUILD_EFFECT" (waylandEnabled))
    (lib.cmakeBool "BUILD_EFFECTX11" (!waylandEnabled))
    (lib.cmakeBool "BUILD_DECORATION" false)
  ];
}
