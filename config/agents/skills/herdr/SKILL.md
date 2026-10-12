---
name: herdr
description: "Control Herdr panes, tabs, workspaces, agents, and terminal processes when the user explicitly requests Herdr or another skill requires Herdr. Do not use for generic delegation or background work. Requires HERDR_ENV=1."
---

# Herdr

Herdr organizes workspaces, tabs, and panes. Pane commands control terminals and ordinary processes; agent commands validate agent identity and lifecycle. `agent start` requires an existing shell pane and never creates layout.

## Check context and capabilities

Before inspecting or controlling a session:

```bash
test "${HERDR_ENV:-}" = 1
```

If the check fails, say that you are outside Herdr and stop. Do not inspect or control the user's focused session from outside Herdr.

The installed CLI is the syntax authority. Check help, server status, and the relevant group:

```bash
herdr --help
herdr status
herdr agent                 # or pane, workspace, tab, worktree, terminal,
                            # notification, integration, session, machine, api
```

Do not run bare `herdr`; it launches or attaches the TUI. Do not probe nested mutations without arguments; `workspace create` executes with defaults.

Client and server versions can differ despite protocol compatibility. Check server support before relying on newer features. Missing methods do not authorize upgrades or restarts. `api schema --json` describes the installed binary, not the live server.

Most responses are JSON; parse returned IDs and state. Reads print terminal text. Server errors print JSON on stderr and exit 1; syntax errors exit 2.

## Target the caller, not UI focus

Use `--current`, an explicit live ID, or a unique agent name, never sidebar positions, example IDs, or another client's focus.

```bash
herdr pane current --current
herdr pane list --workspace "$HERDR_WORKSPACE_ID"
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
herdr workspace list
herdr agent list
```

IDs such as `w1`, `w1:t1`, and `w1:p1` are opaque and server-scoped. Closed tab and pane IDs are not reused.

| Operation | Returned objects or ID |
| --- | --- |
| `workspace create` | `.result.workspace`, `.result.tab`, `.result.root_pane` |
| `tab create` | `.result.tab`, `.result.root_pane` |
| `pane split` | `.result.pane.pane_id` |
| `pane move` | `.result.move_result.pane.pane_id` |

Cross-workspace moves change pane IDs; the previous ID is at `.result.move_result.previous_pane_id`. Continue with the new ID or live agent name. Only the moved process's inherited caller context retains the old alias, so `--current` stays safe. Its workspace and tab environment can be stale. Existing waits can end with `agent_not_running`.

An omitted split target uses `HERDR_PANE_ID`, otherwise UI focus. Explicit targets avoid other clients' focus.

Before remote work, read [Saved SSH machines](references/machines.md). TUI machine selection does not retarget CLI commands; remote discovery and control require the same `--machine` prefix.

## Create a sibling pane

Default to the current tab and `$PWD`; use another workspace, tab, worktree, or cwd only when requested.

```bash
herdr pane layout --current
```

Honor the requested direction. Otherwise split wide panes right, narrow or tall panes down. Avoid unusably small repeated splits. Preserve cwd and focus:

```bash
split=$(herdr pane split --current --direction right --cwd "$PWD" --no-focus)
new_pane=$(printf '%s\n' "$split" | jq -er '.result.pane.pane_id')
```

Replace `right` with `down` when needed. Continue only if both commands succeed and the returned ID is nonempty. Use `--no-focus` for background layout changes unless the user asks to switch context.

## Start and coordinate an agent

Targets accept unique live names or agent-hosting pane IDs, not terminal IDs or kind labels. Names match `[a-z][a-z0-9_-]{0,31}` and clear on exit, release, or replacement.

The target shell must own the foreground at its interactive prompt, without a command, editor, or agent. Inspect `pane process-info --pane "$new_pane"` and output if uncertain.

Use the requested kind. For a local Pi helper:

```bash
herdr agent start reviewer --kind pi --pane "$new_pane"
```

Get supported kinds from `herdr agent`; pass native arguments after `--`. Start waits for the expected agent to own the same terminal and accept input, defaulting to 30 seconds. Startup `blocked` returns `agent_not_ready`; the name remains usable for reads and keys. Inspect, ask before answering, then wait for idle before prompting.

```bash
herdr agent prompt reviewer "Review the current diff and report actionable findings." --wait --timeout 120000
herdr agent get reviewer
herdr agent read reviewer --source recent-unwrapped --lines 120
```

`agent prompt` honors bracketed paste and submits text plus encoded Enter in order. Windows Codex also receives a paste boundary. Success without `--wait` confirms writes, not a started turn. Already blocked agents return `agent_blocked` without input.

### States and waits

| State | Meaning |
| --- | --- |
| `working` | Agent work is in progress. |
| `idle`, `done` | Ready for input; `done` is idle but not marked seen by the server. |
| `blocked` | Herdr recognized an approval or question UI. Inspect it; ask before answering. |
| `unknown` | Agent exists, but Herdr cannot classify its state. Not proof of completion. |

Explicit focus commands mark completions seen; reads do not. TUI clients track seen completions independently, so their Done badges can differ from CLI state.

- Prompt `--wait` and standalone `agent wait` default to settled `idle`, `done`, or `blocked`. Do not repeat defaults with `--until`.
- A non-working prompt must produce observed `working` or `blocked` within five seconds after submission. Otherwise, `agent_prompt_stalled` returns, or `timeout` if the caller deadline expires first. Unrelated idle, done, or session changes do not qualify.
- Timeouts include submission. Without one, settled-state waits are indefinite after activity. Waits track lifecycle, not individual turns; an already-working agent's active turn can satisfy the wait.
- Standalone waits return immediately on a matching state. Use `--until` for specific states, repeated for alternatives. Prompt `--until` requires `--wait`.

```bash
herdr agent wait reviewer --until blocked --timeout 120000
herdr agent send-keys reviewer esc
herdr agent send-keys reviewer ctrl+c
```

Herdr validates all logical keys before writing bytes. Read before dismissing, interrupting, or answering UI. On failed, stalled, or blocked waits, inspect `agent get` and `agent read`. Errors do not prove input was undelivered; never blindly resubmit. Pane input is for deliberate raw control.

## Run ordinary processes and read output

Create a sibling pane as described earlier, then use its returned ID:

```bash
herdr pane run "$new_pane" "just test"
herdr pane wait-output "$new_pane" --match "test result" --timeout 120000
herdr pane read "$new_pane" --source recent-unwrapped --lines 120
```

Use the actual command and marker. `pane run` submits text plus Enter atomically; `send-text` does not submit; `send-keys` sends logical keys.

`wait-output` immediately checks existing output, so old text can match. It proves neither lifecycle nor process success. `--match` finds literal substrings; `--regex` uses Rust regex, both one line at a time. Default matching searches 80 unwrapped rendered rows. Set `--source`, `--lines`, and `--timeout` as needed; waits otherwise can be indefinite.

| Read source | Use |
| --- | --- |
| `visible` | Current viewport and interactive UI. |
| `recent` | Recent rendered output with soft wraps. |
| `recent-unwrapped` | Joined soft wraps, preferred for logs and transcripts. |
| `detection` | Plain-text bottom-buffer snapshot for agent detection. Use with `agent read`. |

Reads strip ANSI; use `--format ansi` when styling is evidence. Detection is always plain text. Recent reads default to 80 rows; `--lines` selects rows before unwrapping. Visible and detection reads otherwise return full snapshots.

Alternate-screen output is not host scrollback. At the transcript bottom, larger text reads can collect supported idle agents' application history and restore the viewport. ANSI, visible, detection, and output waits remain passive. `agent_not_idle` on a larger read means wait for idle or use visible output. History is not always recoverable.

If larger reads still miss the response, request Markdown in a temporary directory and only its path as the reply. Read it on that machine. Use this fallback only after reads fail.

## Local setup and safety

- Config is `~/.config/herdr/config.toml`, symlinked into `~/.dotfiles/herdr/`; respect `HERDR_CONFIG_PATH`. Current overrides affect UI and keys, not agent launch. Use CLI control; read current config before shortcut advice. Herdr navigation shortcuts are not agent UI keys.
- Pi's managed `~/.pi/agent/extensions/herdr-agent-state.ts` reports lifecycle and session identity. Diagnose with `herdr integration status`; do not force completion with manual reports or releases. Updates overwrite managed integrations; put custom hooks beside them.
- Close only layouts or sessions you created unless explicitly authorized. `workspace close --group` also closes linked-worktree workspaces, not their checkouts. Never use it just to bypass `workspace_group_close_required`. Closing the last tab closes its workspace.
- `--trust-repository` needs independent verification and grants per-request trust, not a routine retry. Dirty-worktree forced removal needs approval.
- Never kill the main Herdr process. Run `herdr server stop` only when the user explicitly intends to stop the server and its pane processes. Use named test sessions for isolated experiments. Missing features do not authorize server restarts or integration updates.

## Sources and maintenance

Adapted from [dmmulroy's skill](https://github.com/dmmulroy/.dotfiles/blob/main/home/.agents/skills/herdr/SKILL.md), bundled `herdr --skill`, and [release-matched docs](https://herdr.dev/llms.txt). Validated with CLI 0.9.3 and server 0.9.1. Recheck help, status, and config; versions and settings can change.
