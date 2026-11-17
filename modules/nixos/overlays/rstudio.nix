{ inputs }:
final: prev: {
  rstudio = inputs.nixpkgs-copors.legacyPackages.${prev.stdenv.hostPlatform.system}.rstudio;
}
