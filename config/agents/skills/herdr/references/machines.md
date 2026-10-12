# Saved SSH machines

Read before remote discovery or control. IDs and agent names are server-scoped; machines can share `w1:p1` or `reviewer`. TUI machine selection does not retarget this pane's CLI.

## Discover and target

```bash
herdr machine list --json
herdr machine status <label-or-id> --json
herdr --machine <label-or-id> agent list
herdr --machine <label-or-id> pane list
herdr --machine <label-or-id> agent prompt <remote-agent-name> "Report your current status." --wait --timeout 120000
```

Keep the same global prefix throughout. Select an enabled profile ID or unique, case-sensitive label, not an arbitrary SSH hostname. The saved remote session needs no open TUI. Do not combine `--machine` with `--session` or `--remote`.

Discover remote IDs; local inherited IDs and `--current` do not identify remote panes. `machine list` lists profiles, not combined panes. Status checks fresh reachability, not TUI connection state.

## Forwarding limits

Both installations need forwarding support and an already-running, API-compatible remote server. Release versions need not match. Forwarding never installs, starts, restarts, or falls back to Local.

Local config, installation, session management, and interactive attachment do not forward. Check installed help and [CLI docs](https://herdr.dev/llms.txt) for less common operations. Forwardable server stop still needs explicit intent to stop pane processes.

Remote worktree paths must be absolute, `~`, or start with `~/`; plugin link paths must be absolute. Herdr does not copy local config, plugins, executables, or secrets.

Connection failure can follow a successful mutation. Inspect remote state before retrying.

## Profile changes and recovery

- Change profiles only when requested. Removal or disabling disconnects clients, not remote sessions.
- Interactive `machine add` discovers sessions and may ask the user to choose. Noninteractive setup uses `default` unless `--remote-session` is supplied.
- Setup can install, update, and start servers with approval. Replacement stops pane processes and defaults to No; never approve it for the user. Handoff is not implicit.
- Diagnose with `machine status [<label-or-id>] --json`. `machine reconnect` needs user SSH authentication in their terminal; do not run it for them. It does not install or update.
- Version differences alone do not justify stopping servers. Missing capabilities can require an explicitly approved update.
