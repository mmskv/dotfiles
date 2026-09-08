{
  lib,
  pkgs,
  sec,
  ...
}: let
  hosts = sec.mouse;
  selectHost = target:
    pkgs.writeShellScript "switch-to-${target}" ''
      ${lib.optionalString (target == "mac") ''
        ${pkgs.coreutils}/bin/timeout --kill-after=1s 8s \
          ${pkgs.coreutils}/bin/env -u DISPLAY -u WAYLAND_DISPLAY GDK_BACKEND=x11 \
          ${pkgs.solaar}/bin/solaar config ${hosts.unitId} change-host ${toString hosts.macChannel} || true
      ''}
      # Switch the display last, even if the mouse is unavailable. LG input
      # readback is unreliable; use the alternate command without verification.
      # The display is optional, including if it disconnects during the switch.
      if ! ${pkgs.coreutils}/bin/timeout --kill-after=1s 8s \
        ${pkgs.ddcutil}/bin/ddcutil --sn ${lib.escapeShellArg sec.lgDisplay.serial} \
        --noverify --i2c-source-addr=0x50 setvcp f4 ${toString sec.lgDisplay.inputs.${target}}; then
        echo "Skipping LG input switch: display unavailable or DDC command failed" >&2
      fi
    '';
  notify = pkgs.writeShellApplication {
    name = "codex-haptic-notify";
    runtimeInputs = [pkgs.coreutils pkgs.jq pkgs.solaar pkgs.sqlite pkgs.util-linux];
    text = ''
      # Codex passes a notification as a single JSON argument.
      if ! jq -e 'type == "object" and .type == "agent-turn-complete"' \
        >/dev/null 2>&1 <<< "''${1:-}"; then
        exit 0
      fi

      event=$(jq -c '{"thread-id": ."thread-id", "turn-id": ."turn-id"}' <<< "$1")
      thread_id=$(jq -r '."thread-id" // empty' <<< "$1")
      # Restrict the identifier before using it in the read-only SQL query.
      if [[ ! "$thread_id" =~ ^[0-9a-fA-F-]{36}$ ]]; then
        logger -t codex-haptics -- "ignored completion without a valid thread ID: $event" || true
        exit 0
      fi

      # Codex 0.153 also notifies when background sub-agents finish. Look up
      # the notification thread's origin in the local metadata database.
      # If the database is unavailable, keep notifications working and log it.
      if origin=$(sqlite3 -readonly -cmd '.timeout 100' \
        "''${CODEX_HOME:-$HOME/.codex}/state_5.sqlite" \
        "SELECT source FROM threads WHERE id = '$thread_id';" 2>/dev/null); then
        if jq -e 'type == "object" and has("subagent")' >/dev/null 2>&1 <<< "$origin"; then
          logger -t codex-haptics -- "ignored sub-agent completion: $event" || true
          exit 0
        fi
      else
        logger -t codex-haptics -- "session origin unavailable: $event" || true
      fi
      logger -t codex-haptics -- "completion received: $event" || true

      # Solaar 1.1.19 writes once from the CLI, then forwards the same write
      # to its GUI. A haptic is an action: forwarding replays it, potentially
      # later in the GUI's worker queue. Keep this CLI invocation headless.
      # Force X11 with no DISPLAY so GTK cannot fall back to a Wayland socket.
      # Select this MX Master 4 by serial, independent of its receiver slot.
      if timeout --kill-after=1s 8s env -u DISPLAY -u WAYLAND_DISPLAY GDK_BACKEND=x11 \
        solaar config 9C75206B haptic-play COMPLETED >/dev/null 2>&1; then
        logger -t codex-haptics -- "haptic sent: $event" || true
      else
        logger -t codex-haptics -- "haptic unavailable or failed: $event" || true
      fi
    '';
  };

  python = pkgs.python3.withPackages (p: [p.pyyaml]);
  configure = pkgs.writeText "configure-mx-master-gestures.py" ''
    import os
    from pathlib import Path

    import yaml

    path = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "solaar/config.yaml"
    data = yaml.safe_load(path.read_text()) if path.exists() else ["${pkgs.solaar.version}"]
    if not isinstance(data, list) or not data or not all(isinstance(d, dict) for d in data[1:]):
        raise ValueError("Unexpected Solaar configuration format")

    device = next((d for d in data[1:] if d.get("_unitId") == "9C75206B" or d.get("_serial") == "9C75206B"), None)
    if device is None:
        device = {
            "_NAME": "MX Master 4",
            "_modelId": "B04200000000",
            "_unitId": "9C75206B",
            "_serial": "9C75206B",
            "_wpid": "B042",
        }
        data.append(device)

    # 195 is the Mouse Gesture Button; 2 enables Solaar's movement recognition.
    device.setdefault("divert-keys", {})[195] = 2
    device.setdefault("_sensitive", {})["divert-keys"] = False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(yaml.safe_dump(data, sort_keys=False))
  '';
in {
  # ZMK sends F23/F24 before changing its Bluetooth profile. Local selections
  # also restore the display input, so repeated presses work while typing blind.
  # Keep Solaar headless to avoid forwarding a duplicate switch to its GUI.
  wayland.windowManager.hyprland.settings.bindli = [
    ", F24, exec, ${selectHost "pc"}"
    ", F23, exec, ${selectHost "mac"}"
  ];

  # ~/.codex/config.toml is maintained by Codex; its top-level notify setting
  home.file.".local/bin/codex-haptic-notify".source = "${notify}/bin/codex-haptic-notify";

  xdg.configFile."solaar/rules.yaml".text = ''
    # The gesture completes on release; keep workspace cycling on this monitor.
    ---
    - Device: "9C75206B"
    - MouseGesture: ["Mouse Gesture Button", "Mouse Up"]
    - Execute: ["/run/current-system/sw/bin/hyprctl", "dispatch", "workspace", "m-1"]
    ...
    ---
    - Device: "9C75206B"
    - MouseGesture: ["Mouse Gesture Button", "Mouse Down"]
    - Execute: ["/run/current-system/sw/bin/hyprctl", "dispatch", "workspace", "m+1"]
    ...
  '';

  systemd.user.services.solaar = {
    Unit = {
      Description = "Logitech mouse gesture recognition";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      # Seed only the gesture setting, including when the mouse is asleep.
      # Solaar applies it whenever the device connects.
      ExecStartPre = "${python}/bin/python3 ${configure}";
      ExecStart = "${pkgs.solaar}/bin/solaar --window=hide";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
