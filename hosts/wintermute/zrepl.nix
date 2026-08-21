{
  config,
  sec,
  ...
}: {
  services.zrepl = {
    enable = true;

    settings = {
      global.logging = [
        {
          type = "syslog";
          level = "info";
          format = "human";
        }
      ];

      jobs = [
        {
          type = "push";
          name = "backup_home";

          conflict_resolution.initial_replication = "all";

          connect = {
            type = "tls";
            address = sec.zrepl.Hosaka.addr;
            ca = config.age.secrets."zrepl/ca.crt".path;
            cert = config.age.secrets."zrepl/Wintermute.crt".path;
            key = config.age.secrets."zrepl/Wintermute.key".path;
            server_cn = "Hosaka";
          };

          filesystems = {
            "rpool/home" = true;
            "rpool/persist" = true;
          };

          snapshotting = {
            type = "periodic";
            interval = "10m";
            prefix = "zrepl_";
          };

          pruning = {
            keep_sender = [
              {type = "not_replicated";}
              {
                type = "regex";
                regex = "^manual_.+";
              }
              {
                type = "grid";
                grid = "1x1h(keep=all) | 24x1h | 35x1d | 3x30d";
                regex = "^zrepl_.*";
              }
            ];
            keep_receiver = [
              {
                type = "regex";
                regex = "^manual_.*";
              }
              {
                type = "grid";
                grid = "1x1h(keep=all) | 10x5h | 35x1d | 24x30d";
                regex = "^zrepl_.*";
              }
            ];
          };
        }
      ];
    };
  };
}
