{
  pkgs,
  lib,
  sec,
  ...
}: let
  cfg = sec.mac.workVpn;

  mgmtSocket = "/tmp/openvpn-work.sock";
  logFile = "/tmp/openvpn-work.log";
  dnsKey = "State:/Network/Service/openvpn-work/DNS";

  ovpn = pkgs.openvpn.override {pkcs11Support = true;};

  dnsScript = pkgs.writeShellScript "openvpn-work-dns" ''
    set -eu
    if [ "$script_type" = down ]; then
      /usr/sbin/scutil <<<"remove ${dnsKey}"
      exit 0
    fi
    servers=""
    i=1
    while var="foreign_option_$i"; val="''${!var-}"; [ -n "$val" ]; do
      case "$val" in "dhcp-option DNS "*) servers="$servers ''${val#dhcp-option DNS }" ;; esac
      i=$((i+1))
    done
    [ -n "$servers" ] || exit 0
    /usr/sbin/scutil <<EOF
    d.init
    d.add ServerAddresses * $servers
    d.add SupplementalMatchDomains * ${lib.concatStringsSep " " cfg.dnsDomains}
    set ${dnsKey}
    EOF
  '';

  pinFeeder = pkgs.writeShellScript "openvpn-work-pin" ''
    exec ${pkgs.python3}/bin/python3 -c '
    import os, re, socket, time
    s = socket.socket(socket.AF_UNIX)
    for _ in range(200):
        try: s.connect("${mgmtSocket}"); break
        except OSError: time.sleep(0.05)
    buf = b""
    while True:
        d = s.recv(4096)
        if not d: break
        buf += d
        m = re.search(rb">PASSWORD:Need \x27([^\x27]+)\x27", buf)
        if m:
            s.sendall(b"password \"" + m.group(1) + b"\" " + os.environ["PIN"].encode() + b"\n")
            break
    '
  '';

  ovpnRoot = pkgs.writeShellScript "openvpn-work-root" ''
    set -eu
    rm -f ${mgmtSocket}
    /usr/sbin/scutil <<<"remove ${dnsKey}" >/dev/null || true
    exec ${ovpn}/bin/openvpn \
      --config ${cfg.config} \
      --management ${mgmtSocket} unix \
      --management-client-user ${sec.mac.user} \
      --management-query-passwords \
      --script-security 2 \
      --up ${dnsScript} \
      --down ${dnsScript} \
      --pull-filter ignore "ping-restart" \
      --ping 10 \
      --ping-exit 30
  '';

  #
  # 90s debounce is to guard against a feedback loop
  watcherScript = pkgs.writeShellScript "openvpn-work-watcher" ''
    LOCK=/tmp/openvpn-work-watcher.last
    if [ -f "$LOCK" ]; then
      age=$(( $(date +%s) - $(/usr/bin/stat -f %m "$LOCK") ))
      [ "$age" -lt 90 ] && exit 0
    fi
    date +%s > "$LOCK"
    exec /bin/launchctl kickstart -k "gui/$(/usr/bin/id -u)/org.users.openvpn-work"
  '';

  startScript = pkgs.writeShellScript "openvpn-work-start" ''
    set -eu
    ${pkgs.gnupg}/bin/gpgconf --kill scdaemon 2>/dev/null || true
    PIN=${lib.escapeShellArg cfg.pin} ${pinFeeder} &
    exec /usr/bin/sudo -n ${ovpnRoot}
  '';
in {
  environment.etc."sudoers.d/openvpn-work".text = ''
    ${sec.mac.user} ALL=(root) NOPASSWD: ${ovpnRoot}
  '';

  launchd.user.agents.openvpn-work = {
    serviceConfig = {
      Label = "org.users.openvpn-work";
      ProgramArguments = ["${startScript}"];
      RunAtLoad = false;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };

  launchd.user.agents.openvpn-work-watcher = {
    serviceConfig = {
      Label = "org.users.openvpn-work-watcher";
      ProgramArguments = ["${watcherScript}"];
      RunAtLoad = false;
      LaunchEvents."com.apple.notifyd.matching".network-change = {
        Notification = "com.apple.system.config.network_change";
      };
    };
  };
}
