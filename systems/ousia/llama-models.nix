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
    sm = "tensor";
    ts = "2.8,1";
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
  qwen-flash-next = pkgs.homa.fetchHuggingFaceModel {
    repo = "unsloth/Qwen3.8-Flash-Next-GGUF";
    version = "d96201194f103c906994f283f504209dc8d2a10c";
    scripts = {
      set-split = {
        file = "engram/set_split.py";
        hash = "sha256-6zvpdh6D7U4y8gBoC2LoXIrV3/xlRFL3eooRtdoaRcU=";
      };
    };
    files = { scripts, ... }: [
      {
        file = "UD-IQ3_XXS/Qwen3.8-Flash-Next-UD-IQ3_XXS-00001-of-00004.gguf";
        hash = "sha256-nVZEs3H/rJIUJ8gCHMckLauOO6N9e0jR55/jdw+/mRU=";
      }
      {
        file = "UD-IQ3_XXS/Qwen3.8-Flash-Next-UD-IQ3_XXS-00002-of-00004.gguf";
        hash = "sha256-qsr/O9uQMsLDvkKBZ5MICXNfZdPPsgTroH2F5CHn3fQ=";
      }
      {
        file = "UD-IQ3_XXS/Qwen3.8-Flash-Next-UD-IQ3_XXS-00003-of-00004.gguf";
        hash = "sha256-748U55CrRxs2PxRtXoZk7vuvA+V3bzF6H7lqK8dwewc=";
      }
      {
        file = "UD-IQ3_XXS/Qwen3.8-Flash-Next-UD-IQ3_XXS-00004-of-00004.gguf";
        hash = "sha256-Xei12/iUCazDlGjeyv1KSpWxPCnYihSwNWEHiXgp7DY=";
      }
      {
        file = "engram-Q8_0.gguf";
        sourceFile = "engram/Qwen3.8-Flash-Next-engram-Q8_0.gguf_file";
        hash = "sha256-Q3W5JaOr+zhZ9rY02vqrM0PZ4s35s0UiU75GWhI2FCY=";
        postFetch = "${pkgs.python3}/bin/python3 ${scripts.set-split} $downloadedFile 4 4";
      }
    ];
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
    "Qwen/Qwen3.8-Flash-Next" = qwen-thinking-params // {
      m = "${qwen-flash-next}/UD-IQ3_XXS/Qwen3.8-Flash-Next-UD-IQ3_XXS-00001-of-00004.gguf";
      # The model is ~85 GiB: ~56 GiB of main weights plus a 28.8 GiB
      # per-layer n-gram table. VRAM (24 GiB + 12 GiB) is only 36 GiB,
      # so ~23 layers of routed experts (~22 GiB) have to stay in system
      # RAM to leave room for KV cache.
      n-cpu-moe = 23;
      # Keep the 28.8 GiB n-gram table out of VRAM and read only the rows
      # each token needs, straight from the read-only mmap'd shard.
      override-tensor = "per_layer_token_embd=CPU";
      load-mode = "none";
      lazy-mode = "on";
      c = 131072;
      ctk = "q8_0";
      ctv = "q8_0";
      dev = "ROCm0,CUDA0";
      # Layer split beats tensor split with MoE cache.
      sm = "layer";
      ts = "4.3,1";
      # 768 MiB is the most that still fits next to the full 131k Q8_0
      # context. Misses stay on the CPU rather than being uploaded over PCIe.
      moe-cache-mib = 768;
      moe-cache-cpu-share = 0.8;
      ngl = 999;
      batch-size = 2048;
      ubatch-size = 512;
      threads = 12;
      np = 1;
      fit = "off";
      jinja = true;
      ag = true;
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
    thinkingLevelMap = {
      xhigh = "xhigh";
      medium = "medium";
      low = "low";
      high = null;
      minimal = null;
      max = null;
    };
  };
  mkPiModels = pkgs.homa.mkPiModelsFromPreset models-preset;
}
