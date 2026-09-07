"""Internal worker for display mode, color and brightness systemd units."""

import argparse
from datetime import datetime
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time


MODES = ("auto", "day", "night")


def atomic_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as f:
        temporary = Path(f.name)
        try:
            f.write(text)
            f.flush()
            os.fsync(f.fileno())
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)


def read_mode(path):
    try:
        mode = path.read_text().strip()
    except FileNotFoundError:
        return "auto"
    if mode not in MODES:
        print("Invalid saved display mode; using auto", file=sys.stderr)
        return "auto"
    return mode


def current_profile(mode, schedule, now):
    if mode != "auto":
        return mode
    clock = now.hour * 60 + now.minute
    day, night = (
        sum(int(part) * factor for part, factor in zip(schedule[key].split(":"), (60, 1)))
        for key in ("day", "night")
    )
    daytime = day <= clock < night if day < night else clock >= day or clock < night
    return "day" if daytime else "night"


def run(command, timeout=8):
    result = subprocess.run(command, capture_output=True, text=True, timeout=timeout)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or f"{command[0]} failed")
    return result.stdout


def clear_brightness_cache(runtime_dir):
    with (runtime_dir / "brightness.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        (runtime_dir / "brightness.json").unlink(missing_ok=True)


def apply_brightness(policy, profile, outputs, cache, now, execute=run):
    """Return only verified targets; absent/asleep/failed outputs remain retryable."""
    updated = {}
    errors = []
    for monitor in policy["monitors"]:
        key = monitor["name"]
        matches = [
            output for output in outputs
            if output.get("model") == monitor["model"]
            and (not monitor["serial"] or output.get("serial") == monitor["serial"])
        ]
        if len(matches) != 1:
            continue
        output = matches[0]
        if output.get("disabled", False) or not output.get("dpmsStatus", False):
            continue
        target = monitor[profile]
        previous = cache.get(key, {})
        if (previous.get("target") == target and previous.get("connector") == output["name"]
                and 0 <= now - previous.get("checked", 0) < 60):
            updated[key] = previous
            continue
        selector = [policy["commands"]["ddcutil"], "--mfg", monitor["mfg"], "--model", monitor["model"]]
        if monitor["serial"]:
            selector += ["--sn", monitor["serial"]]
        try:
            value = execute(selector + ["getvcp", "10", "--brief"])
            match = re.search(r"^VCP 10 C (\d+) (\d+)\s*$", value, re.MULTILINE)
            if not match or int(match[2]) <= 0:
                raise RuntimeError("Unreadable DDC brightness range")
            current, maximum = map(int, match.groups())
            raw_target = (target * maximum + 50) // 100
            if current != raw_target:
                execute(selector + ["setvcp", "10", str(raw_target)])
            updated[key] = {"target": target, "connector": output["name"], "checked": now}
        except (RuntimeError, subprocess.TimeoutExpired, OSError) as error:
            errors.append(f"{key}: {error}")
    return updated, errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", required=True, type=Path)
    actions = parser.add_subparsers(dest="command", required=True)
    actions.add_parser("select-mode").add_argument("mode", choices=MODES)
    for action in ("refresh", "apply-brightness", "run-hyprsunset"):
        actions.add_parser(action)
    args = parser.parse_args()
    policy = json.loads(args.config.read_text())
    state_dir = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "display-mode"
    mode_file = state_dir / "mode"
    mode = read_mode(mode_file)

    if args.command == "run-hyprsunset":
        binary = policy["commands"]["hyprsunset"]
        os.execv(binary, [binary, "--config", policy["profiles"][mode]])

    runtime_dir = Path(os.environ["XDG_RUNTIME_DIR"]) / "display-mode"
    runtime_dir.mkdir(parents=True, exist_ok=True)

    systemctl = [policy["commands"]["systemctl"], "--user"]
    if args.command == "select-mode":
        state_dir.mkdir(parents=True, exist_ok=True)
        with (state_dir / "mode.lock").open("w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            atomic_write(mode_file, args.mode + "\n")
            clear_brightness_cache(runtime_dir)
            # Deliberately reload the selected configuration on mode changes.
            # These independent units start concurrently; no IPC readiness sleep.
            run(systemctl + ["restart", "hyprsunset.service", "display-brightness.service"], timeout=55)
        mode = args.mode

    profile = current_profile(mode, policy["schedule"], datetime.now())
    if args.command == "select-mode":
        print(f"Mode: {mode}; current profile: {profile}")
        print("Temperature: " + ("default colors" if profile == "day" else f'{policy["nightTemperature"]} K'))
        for monitor in policy["monitors"]:
            print(f'{monitor["name"]}: {monitor[profile]}% target brightness')
        return 0

    if args.command == "refresh":
        clear_brightness_cache(runtime_dir)
        run(systemctl + ["--no-block", "start", "display-brightness.service"])
        return 0

    cache_file = runtime_dir / "brightness.json"
    with (runtime_dir / "brightness.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            cache = json.loads(cache_file.read_text())
            if not isinstance(cache, dict):
                cache = {}
        except (FileNotFoundError, ValueError):
            cache = {}
        # Re-read after acquiring the lock: a manual override may have changed.
        profile = current_profile(read_mode(mode_file), policy["schedule"], datetime.now())
        outputs = json.loads(run([policy["commands"]["hyprctl"], "-j", "monitors", "all"]))
        cache, errors = apply_brightness(policy, profile, outputs, cache, time.monotonic())
        atomic_write(cache_file, json.dumps(cache))
        for error in errors:
            print(error, file=sys.stderr)
        return int(bool(errors))


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, subprocess.TimeoutExpired, OSError) as error:
        print(f"display-mode: {error}", file=sys.stderr)
        sys.exit(1)
