{
  pkgs,
  mkAeroDerivation,
}:
mkAeroDerivation {
  pname = "aero-components";
  src = pkgs.repos.aero-workspace;
  ninjaFlags = [
    "aeroshell_components"
    "aeroshell_components_private"
  ];
  buildInputs = with pkgs.kdePackages; [
    libksysguard
    plasma-workspace
  ];
  installPhase = ''
    runHook preInstall
    ninja components/install
    runHook postInstall
  '';
}
