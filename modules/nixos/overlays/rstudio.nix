{ inputs }:
final: prev: {
  rstudio = inputs.nixpkgs-rstudio-opencode.legacyPackages.${prev.stdenv.hostPlatform.system}.rstudio;
}
