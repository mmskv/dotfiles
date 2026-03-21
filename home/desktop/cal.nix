{sec, ...}: {
  services.vdirsyncer = {
    enable = true;

    frequency = "*:0/15";
  };

  programs.vdirsyncer.enable = true;

  programs.khal = {
    enable = true;
    locale = {
      timeformat = "%H:%M";
      dateformat = "%d/%m/%Y";
      longdateformat = "%d/%m/%Y";
      datetimeformat = "%d/%m/%Y %H:%M";
      longdatetimeformat = "%d/%m/%Y %H:%M";
    };
  };

  accounts.calendar.accounts.radicale = {
    khal = {
      enable = true;
      type = "discover";
      glob = "*";
    };
    vdirsyncer = {
      enable = true;
      collections = ["from a" "from b"];
      conflictResolution = "remote wins";
    };
    local = {
      type = "filesystem";
      fileExt = ".ics";
      path = "~/.local/share/calendars";
    };
    remote = {
      type = "caldav";
      url = sec.vdirsyncer.url;
      userName = sec.vdirsyncer.user;
      passwordCommand = ["echo" sec.vdirsyncer.password];
    };
  };
}
