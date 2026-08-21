{sec, pkgs-unstable, ...}: {
  networking.firewall.allowedTCPPorts = [
    6443 # api

    80
    8080
    443
    8443
  ];

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs-unstable.k3s_1_36;

    extraFlags = toString [
      "--disable traefik"
      "--disable metrics-server"
      "--disable-network-policy"
      "--flannel-backend=none"
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };

  virtualisation.containerd = {
    enable = true;
    settings = {
      plugins."io.containerd.grpc.v1.cri".cni = {
        bin_dir = "/opt/cni/bin"; # Not nix way but what can I do
      };
    };
  };

  fileSystems."/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs" = {
    device = "wrpool/containerd";
    fsType = "zfs";
  };

  networking.interfaces.eno2.ipv4.addresses = [
    {
      address = sec.net.Hosaka.lbIp;
      prefixLength = 24;
    }
  ];

  environment.persistence."/persist".directories = [
    "/etc/rancher"

    "/var/lib/containerd/io.containerd.content.v1.content"
    "/var/lib/containerd/io.containerd.metadata.v1.bolt"
    "/var/lib/containerd/io.containerd.grpc.v1.cri"
    "/var/lib/containerd/io.containerd.grpc.v1.introspection"
    "/var/lib/containerd/io.containerd.runtime.v2.task"

    "/var/lib/rancher/"
    "/var/lib/calico/"
    "/var/lib/kubelet/pods"
    "/etc/cni"
    "/opt/cni"
  ];
}
