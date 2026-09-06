{pkgs, ...}: let
  notify = pkgs.writeShellApplication {
    name = "codex-haptic-notify";
    runtimeInputs = [pkgs.coreutils pkgs.jq pkgs.solaar];
    text = ''
      # Codex passes a notification as a single JSON argument.
      if ! jq -e 'type == "object" and .type == "agent-turn-complete"' \
        >/dev/null 2>&1 <<< "''${1:-}"; then
        exit 0
      fi

      # Select this MX Master 4 by serial, independent of its receiver slot.
      timeout --kill-after=1s 8s solaar config 9C75206B haptic-play COMPLETED \
        >/dev/null 2>&1 || true
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
