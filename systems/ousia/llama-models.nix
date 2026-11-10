{ pkgs, lib, ... }:
let
  qwen-thinking-params = {
    fa = "on";
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
    scripts = final-scripts: {
      set-split = {
        file = "engram/set_split.py";
        hash = "sha256-6zvpdh6D7U4y8gBoC2LoXIrV3/xlRFL3eooRtdoaRcU=";
      };
      engram-Q8_0 = {
        file = "engram/Qwen3.8-Flash-Next-engram-Q8_0.gguf_file";
        hash = "sha256-Q3W5JaOr+zhZ9rY02vqrM0PZ4s35s0UiU75GWhI2FCY=";
        postFetch = "${pkgs.python3}/bin/python3 ${final-scripts.set-split} $downloadedFile 4 4";
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
        sourceFile = scripts.engram-Q8_0;
      }
      # Q4_K_M accepts ~2% fewer drafts than Q8_0 but is 1.3 GiB
      # smaller, allowing for decent context alongside MTP.
      {
        file = "MTP/mtp-Qwen3.8-Flash-Next-shared-Q4_K_M.gguf";
        hash = "sha256-9SGGip4UNxi+9RN3L24E2WQlUeNizyQ5Y20qvb0Unfw=";
      }
      {
        file = "mmproj-BF16.gguf";
        hash = "sha256-LniPjFEdgJPHtDy4ey/X4UIoNAMYBX+PsgyG3y7+I1U=";
      }
      {
        file = "engram/engram-Q8_0-2-2.gguf";
        sourceFile = pkgs.runCommand "engram-Q8_0-2-2" { } ''
          cp --reflink=always ${scripts.engram-Q8_0} $out
          chmod u+w $out
          ${pkgs.python3}/bin/python3 ${scripts.set-split} $out 2 2
        '';
      }
    ];
  };
  qwen-flash-next-params = qwen-thinking-params // {
    dev = "ROCm0,CUDA0";
    ngl = 999;
    b = 2048;
    ub = 512;
    t = 12;
    np = 1;
    fit = "off";
    jinja = true;
    ag = true;
    image-min-tokens = 1024;
  };
  qwen-flash-next-gsq-rco = pkgs.homa.fetchHuggingFaceModel {
    repo = "ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF";
    version = "ed59f92082b1e93c0e96d60a8b11aab089b52f09";
    files = [
      {
        file = "IQ3_XXS/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00001-of-00002.gguf";
        hash = "sha256-IZ6pKZAN+p7wkfOqRz/bpodLZfyzZSbX2FGsnpWFbRU=";
      }
      {
        file = "IQ3_XXS/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00002-of-00002.gguf";
        sourceFile = "${qwen-flash-next}/engram/engram-Q8_0-2-2.gguf";
      }
    ];
  };
  qwen-flash-next-coder = pkgs.homa.fetchHuggingFaceModel {
    repo = "ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF";
    version = "bba88856f8c3c0c9e40e45f82d05e228b814ac43";
    files = [
      {
        file = "IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf";
        hash = "sha256-v6NkTbSt//By/JRsIJlPKQnSz4mHnYP4CkyBHUAWwhE=";
      }
      {
        file = "IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf";
        sourceFile = "${qwen-flash-next}/engram/engram-Q8_0-2-2.gguf";
      }
    ];
  };
  qwen-flash-next-coder-params = qwen-flash-next-params // {
    m = "${qwen-flash-next-coder}/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf";
    md = "${qwen-flash-next}/MTP/mtp-Qwen3.8-Flash-Next-shared-Q4_K_M.gguf";
    mm = "${qwen-flash-next}/mmproj-BF16.gguf";
    ncmoe = 0;
    # ^ matters; without it, every blk.N.attn_output.weight also matches.
    ot = "per_layer_token_embd\\.weight=CPU,^output\\.weight=ROCm0";
    lm = "none";
    lzm = "on";
    sm = "layer";
    ts = "2.55,1";
    spec-type = "draft-mtp";
    spec-draft-n-max = 3;
    devd = "CUDA0";
    spec-draft-n-ubatch = 16;
    spec-draft-sampling = "probabilistic";
    ctkd = "q8_0";
    ctvd = "q8_0";
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
    "Qwen/Qwen3.8-Flash-Next" = qwen-flash-next-params // {
      m = "${qwen-flash-next}/UD-IQ3_XXS/Qwen3.8-Flash-Next-UD-IQ3_XXS-00001-of-00004.gguf";
      # The model is ~85 GiB: ~56 GiB of main weights plus a 28.8 GiB
      # per-layer n-gram table. VRAM (24 GiB + 12 GiB) is only 36 GiB,
      # so ~23 layers of routed experts (~22 GiB) have to stay in system
      # RAM to leave room for KV cache.
      ncmoe = 23;
      # Keep the 28.8 GiB n-gram table out of VRAM and read only the rows
      # each token needs, straight from the read-only mmap'd shard.
      ot = "per_layer_token_embd\\.weight=CPU,output\\.weight=ROCm0";
      lm = "none";
      lzm = "on";
      c = 131072;
      ctk = "q8_0";
      ctv = "q8_0";
      # Layer split beats tensor split with MoE cache.
      sm = "layer";
      ts = "3.85,1";
      moe-cache-mib = 1408;
      moe-cache-cpu-share = 0.8;
    };
    "Qwen/Qwen3.8-Flash-Next-GSQ-RCO" = qwen-flash-next-params // {
      m = "${qwen-flash-next-gsq-rco}/IQ3_XXS/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00001-of-00002.gguf";
      # ~44 GiB of main weights (the 54.4 GiB n-gram table is the second shard),
      # so fewer expert layers have to stay in system RAM than UD-IQ3_XXS.
      ncmoe = 20;
      ot = "per_layer_token_embd\\.weight=CPU,output\\.weight=ROCm0";
      lm = "none";
      lzm = "on";
      c = 131072;
      ctk = "q8_0";
      ctv = "q8_0";
      sm = "layer";
      ts = "3.45,1";
      moe-cache-mib = 1280;
      moe-cache-cpu-share = 0.8;
    };
    # IQ1_M is only ~27.6 GiB of main weights (256 experts after RCO
    # pruning), so all 48 layers and every expert fit in the 36 GiB of VRAM.
    # With no host experts the MoE cache is not needed.
    "Qwen/Qwen3.8-Flash-Next-Coder" = qwen-flash-next-coder-params // {
      no-mmproj-offload = true;
      c = 163840;
      ctk = "q8_0";
      ctv = "q8_0";
    };
    # Vision variant with the projector offloaded to CUDA0. The BF16 projector
    # does not fit next to the whole MTP head, so we evict some of the draft
    # head's tensors to RAM.
    "Qwen/Qwen3.8-Flash-Next-Coder-Vision" = qwen-flash-next-coder-params // {
      mmdev = "CUDA0";
      c = 131072;
      ctk = "q8_0";
      ctv = "q8_0";
      otd = "blk\\.48\\.ffn_(down|gate)_exps\\.weight=CPU";
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
