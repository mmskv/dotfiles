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
    dogdns
    nh
    btop
    bpftrace
    parallel

    python3
    rustc
    cargo

    pkgs.man-pages
    pkgs.man-pages-posix

    (pkgs.writeShellScriptBin "vim" "exec nvim $@")
    (pkgs.writeShellScriptBin "sudo" "exec doas $@")
  ];
}
