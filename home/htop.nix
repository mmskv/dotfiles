{...}: {
  programs.htop = {
    enable = true;

    settings = {
      show_cpu_temperature = 1;
      show_program_path = 0;
      show_cpu_usage = 0;
      show_cpu_frequency = 1;
      column_meters_0 = "LeftCPUs4 Memory ZFSARC Tasks";
      column_meter_modes_0 = "1 1 2 2";
      column_meters_1 = "RightCPUs4 LoadAverage DiskIO NetworkIO";
      column_meter_modes_1 = "1 2 2 2";
    };
  };
}
