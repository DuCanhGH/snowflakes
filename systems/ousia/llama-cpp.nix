{
  pkgs,
  config,
  lib,
  ...
}:
(pkgs.llama-cpp.override {
  cudaSupport = true;
  rocmSupport = true;
  blasSupport = true;
  stdenv = pkgs.ccacheStdenv;
}).overrideAttrs
  (oldAttrs: rec {
    version = "11342";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";
      hash = "sha256-fAZMnkrj14vZKvQpC/nfuDQR1Y0w1ZFrh0pf85W7W+Y=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
    npmDepsHash = "sha256-a17M+L3nLdRnN6WMB6imPFmwqG2g8uv+gwN0XTAUrf8=";
    # Heterogeneous (CUDA + ROCm) tensor-parallel AllReduce: drive the
    # foreign rank through its own backend API instead of raw CUDA calls.
    patches = [ ./allreduce-hetero.patch ];
    env = {
      CCACHE_COMPRESS = 1;
      CCACHE_DIR = config.programs.ccache.cacheDir;
      CCACHE_UMASK = "007";
      CCACHE_SLOPPINESS = "random_seed";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
      pkgs.ccache
    ];
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      (lib.cmakeBool "GGML_NATIVE" true)
      (lib.cmakeBool "GGML_CCACHE" true)
    ];
    preConfigure = ''
      export NIX_ENFORCE_NO_NATIVE=0
      ${oldAttrs.preConfigure or ""}
    '';
  })
