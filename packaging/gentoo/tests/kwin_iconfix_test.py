#!/usr/bin/env python3
"""Test iconfix using real KConfig tools and an isolated configuration."""

import configparser
import os
from pathlib import Path
import subprocess
import tempfile


HELPER = Path(__file__).resolve().parents[1] / "dev-vcs/sourcegit/files/sourcegit-kwin-iconfix"
RULE = "78cfa18f-3053-4c0f-9b45-bc51fd595acd"


def read_config(path):
    config = configparser.ConfigParser(interpolation=None)
    config.optionxform = str
    config.read(path)
    return config


def main():
    if os.getuid() == 0:
        raise SystemExit("Run as a normal user; iconfix deliberately skips root.")
    with tempfile.TemporaryDirectory(prefix="sourcegit-kwin-iconfix-test-") as temp:
        root = Path(temp)
        config_dir = root / "config"
        config_dir.mkdir()
        bin_dir = root / "bin"
        bin_dir.mkdir()
        dbus = bin_dir / "qdbus6"
        dbus.write_text(
            '#!/bin/sh\n'
            'case "$*" in\n'
            '  *NameHasOwner*) printf "%s\\n" "${TEST_KWIN_OWNER:-true}" ;;\n'
            '  *reconfigure*) printf "reload\\n" >> "$TEST_RELOAD_LOG" ;;\n'
            '  *) exit 1 ;;\n'
            'esac\n'
        )
        dbus.chmod(0o755)
        config_path = config_dir / "kwinrulesrc"
        original = (
            "[other-window]\nDescription=An unrelated rule\nwmclass=keep-me\n"
            "desktopfile=other-app\n\n[General]\ncount=1\nrules=other-window\n"
        )
        config_path.write_text(original)
        unrelated = dict(read_config(config_path)["other-window"])
        env = os.environ.copy()
        env.update(
            PATH=f"{bin_dir}:{env['PATH']}",
            XDG_CONFIG_HOME=str(config_dir),
            WAYLAND_DISPLAY="test-wayland",
            TEST_RELOAD_LOG=str(root / "reloads"),
        )

        def run(*args, overrides=None):
            subprocess.run(["sh", str(HELPER), *args], env=env | (overrides or {}), check=True)

        run(overrides={"TEST_KWIN_OWNER": "false"})
        assert config_path.read_text() == original
        run(overrides={"WAYLAND_DISPLAY": ""})
        assert config_path.read_text() == original

        run()
        added = read_config(config_path)
        assert dict(added["other-window"]) == unrelated
        assert added["General"]["rules"] == f"other-window,{RULE}"
        assert added["General"]["count"] == "2"
        assert added[RULE]["wmclass"] == "sourcegit"
        assert added[RULE]["desktopfile"] == "sourcegit"
        assert added[RULE]["desktopfilerule"] == "2"

        once = config_path.read_bytes()
        run()
        assert config_path.read_bytes() == once
        assert (root / "reloads").read_text().splitlines() == ["reload"]

        run("--remove")
        removed = read_config(config_path)
        assert removed["General"]["rules"] == "other-window"
        assert removed["General"]["count"] == "1"
        assert dict(removed["other-window"]) == unrelated
        assert not removed.has_section(RULE)

        once = config_path.read_bytes()
        run("--remove")
        assert config_path.read_bytes() == once
        assert (root / "reloads").read_text().splitlines() == ["reload", "reload"]
        print("PASS: inactive sessions, preservation, add, idempotence and remove")


if __name__ == "__main__":
    main()
