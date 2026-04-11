{ pkgs, lib, config, inputs, ... }:

let
  rocmPkgs = pkgs.rocmPackages;

  rocmEnv = pkgs.symlinkJoin {
    name = "rocm-dev";
    paths = with rocmPkgs; [
      clr          # hipcc compiler + HIP runtime
      hipblas      # BLAS for HIP
      rocblas      # underlying BLAS impl
      rocm-core
      rocm-device-libs
      rocm-runtime
      rocminfo
      rocm-comgr   # code object manager
    ];
  };
in
{
  # https://devenv.sh/basics/
  env = {
    HSA_OVERRIDE_GFX_VERSION = "11.5.0";
    ROCM_PATH   = "/opt/rocm";          # compiler toolchain expects this
    HIP_PATH    = "/opt/rocm";
    HIP_DEVICE_LIB_PATH = "${rocmPkgs.rocm-device-libs}/amdgcn/bitcode";
    CMAKE_PREFIX_PATH   = "/opt/rocm";
    AMDGPU_TARGETS = "gfx1150";
  };

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.cmake
    pkgs.vulkan-loader
    pkgs.vulkan-headers
    pkgs.shaderc
    pkgs.pnpm
    pkgs.ninja
    rocmPkgs.clr
    rocmPkgs.hipblas
    rocmPkgs.rocblas
    rocmPkgs.rocm-core
    rocmPkgs.rocm-device-libs
    rocmPkgs.rocm-runtime
    rocmPkgs.rocminfo
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  # https://devenv.sh/basics/
  enterShell = ''
    hello         # Run scripts directly
    git --version # Use packages
    export CC="${rocmPkgs.clr}/bin/hipcc"
    export CXX="${rocmPkgs.clr}/bin/hipcc"
    echo "ROCm env ready — hipcc: $(hipcc --version 2>&1 | head -1)"
    echo "GPU target: $AMDGPU_TARGETS"
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
