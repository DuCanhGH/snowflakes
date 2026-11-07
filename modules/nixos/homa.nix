{ pkgs, lib, ... }:
let
  fetchFromHuggingFace =
    {
      repo,
      file,
      version,
      hash,
      downloadToTemp ? false,
      postFetch ? "",
    }:
    pkgs.fetchurl {
      inherit
        hash
        version
        downloadToTemp
        postFetch
        ;
      pname = "${repo}-${file}";
      url = "https://huggingface.co/${repo}/resolve/${version}/${file}?download=true";
    };
in
{
  inherit fetchFromHuggingFace;
  fetchHuggingFaceModel =
    {
      repo,
      version,
      scripts ? { },
      files,
      postFetch ? "",
    }:
    let
      hfetch =
        args:
        fetchFromHuggingFace (
          {
            inherit repo version;
          }
          // args
        );
      fetched-scripts = lib.mapAttrs (
        _: script:
        hfetch {
          inherit (script) file hash;
          postFetch = script.postFetch or postFetch;
        }
      ) scripts;
      model-files =
        if builtins.isFunction files then
          files {
            inherit hfetch;
            scripts = fetched-scripts;
          }
        else
          files;
    in
    pkgs.linkFarm "${repo}-${version}" (
      map (
        entry:
        let
          is-local-source =
            entry ? sourceFile && (lib.isDerivation entry.sourceFile || builtins.isPath entry.sourceFile);
        in
        {
          name = entry.file;
          path =
            if is-local-source then
              entry.sourceFile
            else
              hfetch (
                (builtins.removeAttrs entry [ "sourceFile" ])
                // {
                  file = entry.sourceFile or entry.file;
                  postFetch = entry.postFetch or postFetch;
                }
              );
        }
      ) model-files
    );
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
