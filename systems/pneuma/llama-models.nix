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
  models-preset = {
    "Qwen/Qwen3.6-35B-A3B" = qwen-thinking-params // {
      m = pkgs.homa.fetchFromHuggingFace {
        repo = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
        file = "Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf";
        version = "5bc3e238d916f48a861bac2f8a1990a0e9b7e98d";
        hash = "sha256-NvnsDkx3X279OmHB6nbwh1EoRpw9AS49niSVqQ56cVA=";
      };
      jinja = true;
      c = 131072;
      np = 1;
      n-cpu-moe = 26;
      kvu = true;
      ctk = "q8_0";
      ctv = "q8_0";
      threads = 6;
      threads-batch = 12;
      batch-size = 2048;
      ubatch-size = 512;
      image-min-tokens = 1024;
    };
  };
in
{
  inherit qwen-thinking-params models-preset;
  qwen-pi-params = {
    input = [
      "text"
      "image"
    ];
    reasoning = true;
  };
  mkPiModels = pkgs.homa.mkPiModelsFromPreset models-preset;
}
