{
  config,
  sec,
  ...
}: let
  tls_config = {
    type = "tls";
    ca = config.age.secrets."zrepl/ca.crt".path;
    cert = config.age.secrets."zrepl/Hosaka.crt".path;
    key = config.age.secrets."zrepl/Hosaka.key".path;
  };
in {
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
          type = "sink";
          name = "warehouse_zrepl";
          root_fs = "warehouse/zrepl";
          serve =
            tls_config
            // {
              listen = sec.zrepl.Hosaka.addr;
              client_cns = ["Hosaka" "Wintermute"];
            };

          recv.properties.override.canmount = "off";
        }
        {
          type = "push";
          name = "backup_wrpool";

          conflict_resolution.initial_replication = "all";

          connect =
            tls_config
            // {
              address = sec.zrepl.Hosaka.addr;
              server_cn = "Hosaka";
            };

          filesystems = {
            "wrpool/home/root" = true;
            "wrpool/services" = true;
          };

          snapshotting = {
            type = "periodic";
            interval = "1h";
            prefix = "zrepl_";
          };

          pruning = {
            keep_sender = [
              {type = "not_replicated";}
              {
                type = "regex";
                regex = "^manual_.*";
              }
              {
                type = "grid";
                grid = "5x1h | 35x1d | 3x30d";
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
                grid = "5x1h | 35x1d | 24x30d";
                regex = "^zrepl_.*";
              }
            ];
          };
        }
        {
          type = "snap";
          name = "snap_warehouse";

          filesystems = {
            "warehouse/databackups" = true;
            "warehouse/sysbackups" = true;
            "warehouse/torrent" = true;
          };

          snapshotting = {
            type = "periodic";
            interval = "1d";
            prefix = "zrepl_";
          };

          pruning = {
            keep = [
              {
                type = "regex";
                regex = "^manual_.*";
              }
              {
                type = "grid";
                grid = "7x1d | 3x10d";
                regex = "^zrepl_.*";
              }
            ];
          };
        }
      ];
    };
  };
}
