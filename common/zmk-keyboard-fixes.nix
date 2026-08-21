{pkgs, ...}: {
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="wheel", MODE="0660"
    # Disable USB autosuspend for Bluetooth adapters to prevent BLE disconnects
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{power/autosuspend}="-1"
    # Restart bluetooth service when BT dongle is replugged so ExecStartPre
    # (hciconfig reset + GATT cache wipe) runs with the adapter present.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2357", ATTR{idProduct}=="0604", RUN+="${pkgs.systemd}/bin/systemctl restart --no-block bluetooth.service"
  '';

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  systemd.services.bluetooth.serviceConfig.ExecStartPre = [
    "-${pkgs.bash}/bin/sh -c 'rm -f /var/lib/bluetooth/*/cache/D4:7B:E5:F2:E1:18'"
  ];

  systemd.services.zmk-flap-watchdog = {
    description = "Restart bluetooth when a ZMK keyboard flaps";
    wantedBy = ["multi-user.target"];
    path = [pkgs.systemd pkgs.coreutils];
    script = ''
      count=0 first=0
      journalctl -k -f -n 0 -o cat -g 'hid-generic 0005:1D50:615E' \
        | while read -r _; do
            ((EPOCHSECONDS - first > 30)) && { first=$EPOCHSECONDS; count=0; }
            if ((++count >= 4)); then
              echo "ZMK HID flap: $count attaches in 30s, restarting bluetooth"
              systemctl restart bluetooth.service
              sleep 60
              count=0
            fi
          done
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = 10;
    };
  };
}
