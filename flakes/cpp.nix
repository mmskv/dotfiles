{pkgs}:
pkgs.mkShell {
  packages = with pkgs; [
    catch2
    cmake
    ninja
    clang-tools
    tbb_2021_11
    libclang
    glog
    llvm
    libxml2
    protobuf
  ];

  shellHook = ''
    export MAKEFLAGS="-j32"
  '';
}
