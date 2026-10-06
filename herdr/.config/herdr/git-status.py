#!/usr/bin/env python3
"""Print the active branch and report colored Git icons for each workspace."""

from concurrent.futures import ThreadPoolExecutor
import json
import os
import subprocess


ICONS = {
    "ahead": ("AheadCount", "↑"),
    "behind": ("BehindCount", "↓"),
    "staged": ("NumStaged", "●"),
    "modified": ("NumModified", "✚"),
    "untracked": ("NumUntracked", "…"),
    "conflict": ("NumConflicts", "✖"),
    "stashed": ("NumStashed", "⚑"),
}
HERDR = os.environ.get("HERDR_BIN_PATH") or "herdr"


def run_json(argv, timeout):
    try:
        result = subprocess.run(
            argv, capture_output=True, check=True, timeout=timeout
        )
        return json.loads(result.stdout)
    except (OSError, subprocess.SubprocessError, ValueError):
        return {}


def git_status(cwd):
    return run_json(["gitmux", "-timeout", "750ms", "-dbg", cwd], 0.85)


def status_tokens(status):
    tokens = {
        "git_" + name: f"{icon} {status[field]}" if status.get(field) else None
        for name, (field, icon) in ICONS.items()
    }
    tokens["git_clean"] = "✔" if status.get("IsClean") else None
    return tokens


def report(workspace_id, cwd, number):
    status = git_status(cwd) if cwd else {}
    tokens = status_tokens(status)
    tokens["space_number"] = str(number)
    argv = [
        HERDR, "workspace", "report-metadata", workspace_id,
        "--source", "dotfiles:git-status", "--ttl-ms", "6000",
    ]
    for name, value in tokens.items():
        argv.extend(["--token", f"{name}={value}"] if value else ["--clear-token", name])
    run_json(argv, 0.5)


def branch_name(status):
    if not status:
        return ""
    if status.get("IsDetached"):
        return ":" + status.get("HEAD", "")
    local = status.get("LocalBranch", "")
    upstream = status.get("RemoteBranch", "")
    return f"{local} → {upstream}" if upstream else local


def main():
    cwd = os.environ.get("HERDR_ACTIVE_PANE_CWD") or os.getcwd()
    with ThreadPoolExecutor(max_workers=8) as executor:
        active_status = executor.submit(git_status, cwd)
        response = run_json([HERDR, "api", "snapshot"], 0.5)
        snapshot = response.get("result", {}).get("snapshot", {})
        directories = {}
        for pane in snapshot.get("panes", []):
            if pane.get("cwd"):
                directories.setdefault(pane["workspace_id"], pane["cwd"])
        # Use the same repository for the active branch and its sidebar icons.
        active_workspace = os.environ.get("HERDR_ACTIVE_WORKSPACE_ID")
        if active_workspace:
            directories[active_workspace] = cwd
        workspaces = [
            (workspace["workspace_id"], directories.get(workspace["workspace_id"]),
             workspace.get("number", index))
            for index, workspace in enumerate(snapshot.get("workspaces", []), 1)
        ]
        list(executor.map(lambda item: report(*item), workspaces))
        branch = branch_name(active_status.result())
    if branch:
        print("⎇ " + branch)


if __name__ == "__main__":
    main()
