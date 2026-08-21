{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    openssh
    ripgrep
    wget
    git
    fzf
    file
    tcpdump
    bind
    git-crypt
    zoxide
    jq
    grc
    kubectl
    exiftool
    file
    fd
    doggo
    nh
    btop
    bpftrace
    parallel

    python3
    rustc
    cargo
    rust-analyzer

    pkgs.man-pages
    pkgs.man-pages-posix

    (pkgs.writeShellScriptBin "vim" "exec nvim $@")
    (pkgs.writeShellScriptBin "sudo" "exec doas $@")

    vulkan-hdr-layer-kwin6
  ];
}
