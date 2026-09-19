{ pkgs, lib, ... }:
let
  qwen-thinking-params = {
    flash-attn = "on";
    temp = 1.0;
    top-p = 0.95;
    top-k = 20;
    min-p = 0.0;
    presence-penalty = 0.0;
    repeat-penalty = 1.0;
    reasoning-preserve = true;
  };
  qwen-27b-ud-q6_k = pkgs.homa.fetchFromHuggingFace {
    repo = "unsloth/Qwen3.8-27B-GGUF";
    file = "Qwen3.8-27B-UD-Q6_K.gguf";
    version = "4ca720788d1e01f1bff70c033e0d0028fd02e502";
    hash = "sha256-ycIGgS++Sse3anKeJZKLY/KuidN/adp6ccIK7HY81DY=";
  };
  qwen-27b-params = qwen-thinking-params // {
    mmproj = pkgs.homa.fetchFromHuggingFace {
      repo = "unsloth/Qwen3.8-27B-GGUF";
      file = "mmproj-BF16.gguf";
      version = "4ca720788d1e01f1bff70c033e0d0028fd02e502";
      hash = "sha256-g+5PTyBfpRQWF3jEHfHqFBRPqg9xNRCJO2PCOV9cLVM=";
    };
    ag = true;
    dev = "ROCm0,CUDA0";
    ts = "2.5,1";
    jinja = true;
    ngl = 999;
    np = 4;
    kvu = true;
    spec-type = "draft-mtp,ngram-mod";
    spec-draft-n-max = 2;
    threads = 12;
    batch-size = 2048;
    ubatch-size = 512;
    image-min-tokens = 1024;
  };
  models-preset = {
    "Qwen/Qwen3.8-27B" = qwen-27b-params // {
      m = qwen-27b-ud-q6_k;
      c = 169216;
      ctk = "f16";
      ctv = "f16";
      no-mmproj-offload = true;
    };
    "Qwen/Qwen3.8-27B-Vision" = qwen-27b-params // {
      m = qwen-27b-ud-q6_k;
      c = 131072;
      ctk = "f16";
      ctv = "f16";
    };
  };
in
{
  inherit qwen-thinking-params models-preset;
  qwen-opencode-params = {
    modalities.input = [
      "text"
      "audio"
      "image"
      "video"
      "pdf"
    ];
    options = {
      reasoningEffort = "xhigh";
      textVerbosity = "low";
      reasoningSummary = "auto";
    };
    variants = lib.genAttrs [ "medium" "low" ] (reasoningEffort: {
      inherit reasoningEffort;
      textVerbosity = "low";
      reasoningSummary = "auto";
    });
  };
  mkOpencodeModels =
    models:
    lib.mapAttrs (
      name: params:
      let
        preset = models-preset.${name};
        ctx = preset."fit-ctx" or preset."fitc" or preset."ctx-size" or preset.c or 0;
      in
      params
      // {
        limit = {
          context = ctx;
          output = ctx / 2;
        }
        // (params.limit or { });
      }
    ) models;
}
