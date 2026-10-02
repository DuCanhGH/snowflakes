{ inputs }:
final: prev: {
  rstudio = inputs.nixpkgs-rstudio.legacyPackages.${prev.stdenv.hostPlatform.system}.rstudio;
}
