{ ... }:
{
  boot = {
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "amdgpu.ppfeaturemask=0xfffd7fff" ];
  };

  systemd.services.amdgpu-fix = {
    description = "Fixes amdgpu gfx timeout";
    after = [
      "suspend.target"
      "multi-user.target"
      "systemd-user-sessions.service"
    ];
    wantedBy = [
      "sleep.target"
      "multi-user.target"
    ];
    wants = [ "modprobe@amdgpu.service" ];
    script = ''
      echo 'high' > /sys/devices/pci0000:00/0000:00:08.1/0000:0b:00.0/drm/card1/device/power_dpm_force_performance_level
    '';
    serviceConfig.Type = "oneshot";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
