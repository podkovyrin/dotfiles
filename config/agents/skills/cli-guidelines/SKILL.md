---
name: cli-guidelines
description: Apply the CLI Guidelines to design, implement, or review command-line tools and terminal UX. Use when creating or auditing commands, subcommands, flags, help text, stdout and stderr behavior, output formats, error messages, prompts, confirmations, configuration, environment variables, naming, distribution, or general CLI usability.
---

# CLI Guidelines

## Overview

Use this skill to translate the CLI Guidelines into concrete interface and implementation decisions. Treat the guide as a source of defaults, and explain clearly when a deliberate exception is better for the current tool.

## Workflow

1. Identify the request mode.
   - Design a new CLI.
   - Review an existing CLI or CLI-focused change.
   - Fix one interaction problem such as help text, flags, prompts, or output.
2. Inspect the current interface before recommending changes.
   - Read the command shape, help output, examples, error messages, and any machine-readable modes.
   - Note whether the tool is primarily human-facing, script-facing, or both.
3. Read only the relevant reference sections from [cli-guidelines.md](references/cli-guidelines.md).
   - Use `rg -n '^### ' references/cli-guidelines.md` to find sections quickly.
   - Start with `The Basics`, `Help`, `Output`, `Errors`, `Arguments and flags`, and `Interactivity`.
   - Read `Configuration`, `Environment variables`, `Naming`, `Distribution`, or `Future-proofing` only when the task touches those areas.
   - Read `Philosophy` when tradeoffs are ambiguous and the user needs rationale, not just rules.
4. Evaluate the interface against the default expectations.
   - Design for humans first without sacrificing scripting.
   - Keep machine-readable data on `stdout` and guidance, logs, and errors on `stderr`.
   - Return `0` on success and meaningful non-zero codes on failure.
   - Prefer explicit flags, standard flag names, and discoverable examples.
   - Make interactivity optional and keep a non-interactive path for automation.
   - Confirm dangerous actions and support `--dry-run`, `--force`, or explicit confirmation when appropriate.
   - Keep output concise by default, but expose `--json` and plain-text or script-friendly modes when they help.
   - Preserve consistency across subcommands, config precedence, and naming.
5. Turn the guideline into an actionable result.
   - For design work, propose command names, subcommand structure, key flags, help text outline, output modes, and confirmation behavior.
   - For review work, report the violated guideline, the user impact, and the smallest concrete fix.
   - For implementation work, make the code change and add validation for help text, exit codes, stdout and stderr separation, or JSON output when practical.

## Review Checklist

Check these questions in roughly this order:

- Does the command parse arguments predictably and use conventional flag names?
- Does running the command with no args, `-h`, or `--help` produce useful help?
- Does help lead with examples and point to fuller documentation?
- Does success output stay brief and readable?
- Does machine-readable output stay stable and explicit, especially with `--json` or plain-text modes?
- Do errors explain what went wrong, what to do next, and how to report unexpected failures?
- Do prompts only appear on a TTY, and does `--no-input` disable them?
- Do dangerous operations require confirmation or a scriptable equivalent?
- Do long-running operations show progress without polluting non-TTY logs?
- Are config, environment variables, and defaults applied with clear precedence?
- Are subcommands and names consistent, unambiguous, and future-proof?

## Reference Map

Use the sections below as entry points in [cli-guidelines.md](references/cli-guidelines.md):

- `### The Basics`: parser choice, exit codes, stdout vs stderr.
- `### Help`: default help behavior, examples, discovery, suggestion flow.
- `### Documentation`: terminal docs, web docs, man pages.
- `### Output`: human-readable defaults, `--plain`, `--json`, color, progress, state reporting.
- `### Errors`: human-centered errors, debug paths, bug-report flow.
- `### Arguments and flags`: flag conventions, prompts, confirmation, stdin and stdout `-`, secrets.
- `### Interactivity`: TTY gating, `--no-input`, password prompts, escape paths.
- `### Subcommands`: hierarchy, naming consistency, ambiguity.
- `### Robustness`, `### Future-proofing`, `### Signals and control characters`: responsiveness, recovery, deprecations, Ctrl-C behavior.
- `### Configuration`, `### Environment variables`, `### Naming`, `### Distribution`, `### Analytics`: operational polish and release concerns.

## Response Style

- Cite the specific command or behavior being discussed.
- Prefer concrete replacement text over abstract advice.
- Explain tradeoffs when recommending a deliberate exception to the guide.
- Avoid repeating the full guide; extract only the rule that matters to the current task.
