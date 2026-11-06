---
name: cua-fast
description: Apply fast session defaults and minimize round trips whenever using cua-driver for native GUI work. Load alongside the upstream cua-driver skill.
---

# Fast Cua sessions

Read the upstream `cua-driver` skill first. Its targeting, permissions, stale-token, failure recovery, and verification rules still apply.

## Start once

Use one unique session label for the task. Start it with these settings before input, then repeat the label on every call that accepts it:

```sh
cua-driver start_session '{"session":"REPLACE-WITH-UNIQUE-LABEL","cursor_motion":{"timing":"fixed","glide_duration_ms":1,"dwell_after_click_ms":0,"arc_size":0,"effects":{"trail":"off","glow":"off","magnet":"off","ripple":"off","squish":"off"}}}'
```

The cursor stays enabled. The requested 1 ms glide removes decorative delay; it is not a guarantee of 1 ms action latency. Do not set the duration to zero: fixed timing treats zero as 1430 ms. End only this session when the task finishes. Do not restart the shared daemon.

The saved global timing is `native` as a fallback. Driver 0.38.0 cannot persist an exact glide duration or click dwell through its supported config keys. Do not put unsupported fields in its config or patch the installed upstream skill.

## Reduce round trips

- Discover the exact window once and reuse its target while valid.
- Use `run_steps` with `observe:{}` for decided actions, including a single action. Keep its default inter-step delay of zero. Add a wait only when the app needs one.
- Use `run_script` for bounded logic that can run locally. Return the result needed for the next decision, not whole trees. Do not script speculative actions or blind retries.
- Keep background delivery. Speed does not authorize foreground fallback or broader permissions.
- Read accessibility data without a screenshot when semantic targeting and verification suffice. Request pixels when visual grounding or outcome verification needs them.
- For a screenshot without a tree, use `include_accessibility_tree:false`. Do not collect both by habit.
- Use one compact tree format. Re-read with `since:"latest"` and the same query and bounds. Diff reads reduce response size but still perform a tree walk.
- Use `query` to reduce returned content. Bound the walk with `max_elements` and `max_depth` when suitable. A missing target in a truncated tree is not proof of absence.
- Verify meaningful checkpoints and the final outcome. Avoid a redundant standalone read immediately after a batch already returned the needed observation.
- Keep the default screenshot resolution unless the task permits a smaller preview. Preserve detail for tiny controls and use the returned coordinate frame.

## Diagnose rather than retry

On `direct_capture_consent_required`, do not repeat capture requests or set an environment bypass. Explain that the user must run `cua-driver permissions grant` and approve the macOS prompt. Tree-only work may continue when it can establish the requested outcome.
