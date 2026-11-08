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
    version = "12194";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";
      hash = "sha256-8BAl8bQ99gldqX7RJfYM6VFtWfeeLrvV9SXAk2ECYwA=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
    # Disable tests for now.
    doCheck = false;
    npmDepsHash = "sha256-XLtEZsSFdk+2SyfXzBp8HQ2e27PQPpDCn1YjePU1/9w=";
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
      (lib.cmakeBool "GGML_BACKEND_DL" true)
      (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    ];
    preConfigure = ''
      export NIX_ENFORCE_NO_NATIVE=0
      ${oldAttrs.preConfigure or ""}
    '';
  })
