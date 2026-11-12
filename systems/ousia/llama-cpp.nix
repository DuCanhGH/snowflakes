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
    version = "12308";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";
      hash = "sha256-+N7xzpXb3wI9UyvdFfQVQYIOwLOVMYUx3bNBmJyovyY=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
    # Disable tests for now.
    doCheck = false;
    npmDepsHash = "sha256-34AKbVBkQZI1+z83Kg4hA43YbxkeDsESKnIt3T5WdL8=";
    # Heterogeneous (CUDA + ROCm) tensor-parallel AllReduce: drive the
    # foreign rank through its own backend API instead of raw CUDA calls.
    # The second patch lets a shared MTP head borrow token_embd/output from the
    # target model through ctx_other.
    patches = [
      ./allreduce-hetero.patch
      ./mtp-shared-embd.patch
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
      (lib.cmakeBool "GGML_NATIVE" true)
      (lib.cmakeBool "GGML_CCACHE" true)
      (lib.cmakeBool "GGML_BACKEND_DL" true)
      (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    ];
    preConfigure = ''
      export NIX_ENFORCE_NO_NATIVE=0
      ${oldAttrs.preConfigure or ""}
    '';
  })
