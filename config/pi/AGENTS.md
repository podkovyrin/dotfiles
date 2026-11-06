# Subagents

These rules override skill defaults. Set `model` and `effort` on every `agent` call, with these exact IDs:

| Work | Model | Effort |
|---|---|---|
| Default: implementation, routine reviews | `claude-bridge/claude-opus-5-5` | medium |
| Design, important reviews | `claude-bridge/claude-opus-5-5` | high |
| Mechanical: exploration, code reading, doc sweeps, verification runs | `openai/gpt-6.1-sol` | medium |
| Exceptional research, very hard decisions | `openai/gpt-6-astra` | high |

- All `claude-bridge` agents share one 5-hour quota. Send work that does not need Opus judgment to `gpt-6.1-sol`.
- If a model is unavailable, tell me before you substitute another.
- Give `gpt-6-astra` a short brief and bounded questions. It can delegate bulk work to cheaper agents.
- Split work into non-overlapping scopes and ask for concise reports. Prefer one focused reviewer to several overlapping reviews.
- Use `xhigh` only when I ask for it.

# Tools

- Search with `grep` and `find` (fff), not `grep -r`, `rg`, `find`, or `fd` in `bash`. Piping output into `grep` is fine.
- Read ranges with `read` and `offset`/`limit`, not `sed -n`, `cat`, or `head`.
- Put independent calls in one response; each turn re-reads the context. Batch many reads or searches in one `codemode` script.
- Run builds and tests that take over 2 minutes in the background, with output to a log file.
- Principle leaves are not listed as skills. Read `~/.pi/agent/git/github.com/michael-denyer/pstack-claude/plugins/pstack/skills/principle-<title>/SKILL.md`.
