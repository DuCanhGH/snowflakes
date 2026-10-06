{ pkgs, lib, ... }:
{
  fetchFromHuggingFace =
    {
      repo,
      file,
      version,
      hash,
    }:
    pkgs.fetchurl {
      inherit hash version;
      pname = "${repo}-${file}";
      url = "https://huggingface.co/${repo}/resolve/${version}/${file}?download=true";
    };
  mkPiModelsFromPreset =
    models-preset: models:
    lib.attrsets.mapAttrsToList (
      name: params:
      let
        preset = models-preset.${name};
        ctx = preset."fit-ctx" or preset."fitc" or preset."ctx-size" or preset.c or 0;
      in
      params
      // {
        id = name;
        contextWindow = ctx;
        maxTokens = ctx / 2;
      }
    ) models;
}
