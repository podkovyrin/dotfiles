// Soften pi-permission-system's wrapper floors.
//
// The permission system clamps `allow` to `ask` for any indirection wrapper
// (env, xargs, nohup, find -exec, ...) and opaque payload (bash -c, eval),
// because a rule on the wrapper text never sees the wrapped command. That is a
// lot of false positives under a permissive `bash: {"*": "allow"}` policy.
//
// This authorizer link answers such asks itself: it re-checks every command
// suffix of the wrapper unit (and every quoted payload) against the real
// policy. Any deny -> deny, any explicit ask -> defer to the human prompt,
// otherwise allow. Enabled by "authorizerChain": ["soft-wrappers"] in
// pi-permission-system/config.json.
// @ts-nocheck

const LINK_NAME = "soft-wrappers";
const SOFT_FLOORS = new Set(["<indirection-bash-wrapper>", "<opaque-bash-wrapper>"]);
const SERVICES_KEY = Symbol.for("@gotgenes/pi-permission-system:session-services");

function isSentinel(pattern) {
  return typeof pattern === "string" && /^<[a-z-]+>$/.test(pattern);
}

/** Candidate inner commands hidden behind a wrapper unit. */
function innerCandidates(unit) {
  const out = new Set();
  const tokens = unit.trim().split(/\s+/);
  for (let i = 1; i < tokens.length; i++) out.add(tokens.slice(i).join(" "));
  for (const m of unit.matchAll(/'([^']*)'|"((?:[^"\\]|\\.)*)"/g)) {
    const body = (m[1] ?? m[2] ?? "").trim();
    if (body) out.add(body);
  }
  return [...out];
}

/** "allow" | "ask" | "deny" for one wrapper unit, judged by its inner commands. */
function judgeUnit(unit, query, agentName) {
  let verdict = "allow";
  for (const candidate of innerCandidates(unit)) {
    const r = query.checkPermission("bash", candidate, agentName ?? undefined);
    if (r.state === "deny") return { state: "deny", candidate, reason: r.reason };
    // A nested floor is fine: the deeper suffixes are checked on their own.
    if (r.state === "ask" && !isSentinel(r.matchedPattern)) verdict = "ask";
  }
  return { state: verdict };
}

async function authorize(details, query, log) {
  const intent = details.accessIntent;
  if (!intent || intent.surface !== "bash") return { kind: "defer" };

  const units =
    intent.askingUnits && intent.askingUnits.length > 0
      ? intent.askingUnits
      : [{ command: details.command ?? intent.matchValues?.[0] ?? "", floor: intent.floor }];

  // Every asking unit must be asking only because of a soft floor.
  if (!units.every((u) => u.command && SOFT_FLOORS.has(u.floor))) return { kind: "defer" };

  for (const u of units) {
    const j = judgeUnit(u.command, query, details.agentName);
    if (j.state === "deny") {
      log.review("soft_wrappers_denied", { requestId: details.requestId, unit: u.command, inner: j.candidate });
      return { kind: "deny", reason: j.reason ?? `Wrapped command is denied by policy: ${j.candidate}` };
    }
    if (j.state === "ask") return { kind: "defer" };
  }

  log.review("soft_wrappers_allowed", { requestId: details.requestId, units: units.map((u) => u.command) });
  return { kind: "allow" };
}

export default function (pi) {
  let dispose;
  pi.events.on("permissions:ready", (data) => {
    const sessionId = data?.sessionId;
    if (dispose || !sessionId) return;
    const service = globalThis[SERVICES_KEY]?.get?.(sessionId);
    dispose = service?.registerAuthorizer(LINK_NAME, authorize);
  });
  pi.on("session_shutdown", () => {
    dispose?.();
    dispose = undefined;
  });
}
