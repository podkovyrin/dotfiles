import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// pstack sets this in every child it starts.
const IS_CHILD = Boolean(process.env.PI_SUBAGENT_PARENT_SESSION);

// A child has no UI and no idle loop, and does no browser work.
const CHILD_DROPPED_TOOL = /^(browser_.*|ask_user_question|schedule_wakeup|visual_explainer)$/;
// Skills for the dropped tools.
const CHILD_DROPPED_SKILL = /\/(pi-browser-use|nicobailon\/visual-explainer)\//;

// pstack runs the parent's model for these.
const PARENT_MODEL_ALIASES = new Set(["inherit-parent", "auto"]);

const AGENT_DIR = process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");

type Policy = { allowedModels: Set<string>; aliases: Map<string, string>; skillExclusions: RegExp[] };

const isStringArray = (v: unknown): v is string[] => Array.isArray(v) && v.every((s) => typeof s === "string");

function readText(file: string): string | undefined {
	try {
		return readFileSync(join(AGENT_DIR, file), "utf8");
	} catch {
		return undefined;
	}
}

function globToRegExp(glob: string): RegExp {
	const body = glob
		.replace(/[.+^${}()|[\]\\]/g, "\\$&")
		.replace(/\*\*/g, "\0")
		.replace(/\*/g, "[^/]*")
		.replace(/\0/g, ".*");
	return new RegExp(`/${body}$`);
}

// pstack resolves model aliases through the "pi models:" line of this sheet.
function readAliases(): Map<string, string> {
	const line = readText("pstack-models.md")?.match(/^pi models:(.*)$/m)?.[1] ?? "";
	const pairs = line.split(",").map((pair) => pair.split("=").map((s) => s.trim()));
	return new Map(pairs.filter(([alias, id]) => alias && id) as [string, string][]);
}

// pstack passes `--skill <plugin>/skills` to children, which bypasses the
// package `skills` filter, so children apply the filter's exclusions here.
function readPolicy(): Policy {
	let raw: unknown;
	try {
		raw = JSON.parse(readText("settings.json") ?? "");
	} catch {
		return { allowedModels: new Set(), aliases: new Map(), skillExclusions: [] };
	}
	if (typeof raw !== "object" || raw === null) return { allowedModels: new Set(), aliases: new Map(), skillExclusions: [] };
	const models = "enabledModels" in raw && isStringArray(raw.enabledModels) ? raw.enabledModels : [];
	const packages = "packages" in raw && Array.isArray(raw.packages) ? raw.packages : [];
	const filters = packages.flatMap((p: unknown) =>
		typeof p === "object" && p !== null && "skills" in p && isStringArray(p.skills) ? p.skills : [],
	);
	return {
		allowedModels: new Set(models),
		aliases: readAliases(),
		skillExclusions: filters.filter((s) => s.startsWith("!")).map((s) => globToRegExp(s.slice(1))),
	};
}

export default function (pi: ExtensionAPI) {
	const { allowedModels, aliases, skillExclusions } = readPolicy();

	pi.on("tool_call", async (event) => {
		if (event.toolName !== "agent" || allowedModels.size === 0) return;
		const model: unknown = event.input.model;
		if (typeof model !== "string" || PARENT_MODEL_ALIASES.has(model)) return;
		const resolved = aliases.get(model) ?? model;
		if (allowedModels.has(resolved)) return;
		const what = resolved === model ? `Model "${model}"` : `Model "${model}" resolves to "${resolved}", which`;
		return {
			block: true,
			reason: `${what} is not allowed. Use one of: ${[...allowedModels].join(", ")}. Pick by the model table in ~/.pi/agent/AGENTS.md.`,
		};
	});

	if (!IS_CHILD) return;

	pi.on("before_agent_start", async (event) => {
		// Blank the entries instead of deleting them: on each later turn Pi merges
		// the base snippets and rules back under the run's.
		const { toolSnippets, toolGuidelines } = event.systemPromptOptions;
		for (const name of Object.keys(toolSnippets)) if (CHILD_DROPPED_TOOL.test(name)) toolSnippets[name] = "";
		for (const name of Object.keys(toolGuidelines)) if (CHILD_DROPPED_TOOL.test(name)) toolGuidelines[name] = [];

		const skills = event.systemPromptOptions.skills;
		const dropped = (path: string) => CHILD_DROPPED_SKILL.test(path) || skillExclusions.some((re) => re.test(path));
		const keptSkills = skills.filter((s) => !dropped(s.filePath));
		if (keptSkills.length !== skills.length) skills.splice(0, skills.length, ...keptSkills);
	});

	// Strip declarations per request, as pi does for hidden tools. Deactivating
	// the tools does not hold: rpiv-ask-user-question re-activates its tool in a
	// later before_agent_start handler, because an RPC child reports a UI.
	const keep = (tool: { name: string }) => !CHILD_DROPPED_TOOL.test(tool.name);
	pi.on("context_with_system", async (event) => ({
		messages: event.messages.map((m) => {
			if (m.role !== "system") return m;
			const { toolsAdded, toolsRemoved, ...rest } = m;
			const added = toolsAdded?.filter(keep) ?? [];
			const removed = toolsRemoved?.filter(keep) ?? [];
			return { ...rest, ...(added.length ? { toolsAdded: added } : {}), ...(removed.length ? { toolsRemoved: removed } : {}) };
		}),
	}));
}
