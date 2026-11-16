{
  pkgs,
  config,
  lib,
  ...
}:
(pkgs.llama-cpp.override {
  stdenv = pkgs.ccacheStdenv;
  cudaSupport = true;
  rocmSupport = true;
  rocmGpuTargets = [ "gfx1100" ];
  blasSupport = true;
}).overrideAttrs
  (oldAttrs: rec {
    version = "12444";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";
      hash = "sha256-S4iGCJHAiiy5TFeC9IHDO56HLvFhnAOVb0E9TC0nQZY=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
    # Disable tests for now.
    doCheck = false;
    npmDepsHash = "sha256-0OJIueUN5oD/V2NtVcXTiRW59u2tJIG3OxW8aJ8JDBY=";
    # Heterogeneous (CUDA + ROCm) tensor-parallel AllReduce: drive the
    # foreign rank through its own backend API instead of raw CUDA calls.
    # The second patch lets a shared MTP head borrow token_embd/output from the
    # target model through ctx_other.
    # The third enables the sparse (top-k masked) flash attention of the Qwen
    # Flash-Next QSA layers on RDNA3/4 via the (4, 4) MMA tile; without it those
    # layers run dense over the full KV cache on gfx1100, and decode slows down
    # linearly with context.
    patches = [
      ./allreduce-hetero.patch
      ./mtp-shared-embd.patch
      ./rdna-sparse-fa.patch
    ];
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
      (lib.cmakeBool "GGML_CCACHE" true)
      (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    ];
  })
