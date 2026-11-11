// Run: node --test compose.test.ts
// Set PI_PACKAGE to the pi-coding-agent package directory, or the test finds it from the `pi` shim on PATH.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { registerHooks } from "node:module";
import { dirname, join, resolve } from "node:path";
import { test } from "node:test";
import { pathToFileURL } from "node:url";

function piPackage(): string {
	if (process.env.PI_PACKAGE) return process.env.PI_PACKAGE;
	const shim = execFileSync("which", ["pi"], { encoding: "utf8" }).trim();
	const target = readFileSync(shim, "utf8").match(/target=(\S+)/)?.[1];
	if (!target) throw new Error(`Cannot find the pi-coding-agent package from ${shim}. Set PI_PACKAGE.`);
	return resolve(dirname(shim), target, "../../..");
}

const piEntry = pathToFileURL(join(piPackage(), "dist/index.js")).href;
registerHooks({
	resolve: (specifier, context, next) =>
		specifier === "@earendil-works/pi-coding-agent" ? { url: piEntry, shortCircuit: true } : next(specifier, context),
});
const { composeMessage, slashName } = await import("./compose.ts");

const P = "Prepend one.\n\nIts second paragraph.";
const A = "Append one.";
const block = '<skill name="bro" location="/s/bro/SKILL.md">\nReferences are relative to /s/bro.\n\nBody.\n</skill>';

const cases: { name: string; text: string; prepends: string[]; appends: string[]; want: string }[] = [
	{ name: "no command, both", text: "hi", prepends: [P], appends: [A], want: `${P}\n\nhi\n\n${A}` },
	{ name: "no command, prepend only", text: "hi", prepends: [P], appends: [], want: `${P}\n\nhi` },
	{ name: "no command, append only", text: "hi", prepends: [], appends: [A], want: `hi\n\n${A}` },
	{ name: "skill with args, both", text: "/skill:bro what  is 2+2 ", prepends: [P], appends: [A], want: `/skill:bro ${P}\n\nwhat  is 2+2\n\n${A}` },
	{ name: "skill with args, prepend only", text: "/skill:bro hi", prepends: [P], appends: [], want: `/skill:bro ${P}\n\nhi` },
	{ name: "skill with args, append only", text: "/skill:bro hi", prepends: [], appends: [A], want: `/skill:bro hi\n\n${A}` },
	{ name: "skill without args, both", text: "/skill:bro", prepends: [P], appends: [A], want: `/skill:bro ${P}\n\n${A}` },
	{ name: "skill without args, prepend only", text: "/skill:bro", prepends: [P], appends: [], want: `/skill:bro ${P}` },
	{ name: "skill without args, append only", text: "/skill:bro", prepends: [], appends: [A], want: `/skill:bro ${A}` },
	{ name: "skill block with text, both", text: `${block}\n\nrecipe`, prepends: [P], appends: [A], want: `${block}\n\n${P}\n\nrecipe\n\n${A}` },
	{ name: "skill block with text, prepend only", text: `${block}\n\nrecipe`, prepends: [P], appends: [], want: `${block}\n\n${P}\n\nrecipe` },
	{ name: "skill block with text, append only", text: `${block}\n\nrecipe`, prepends: [], appends: [A], want: `${block}\n\nrecipe\n\n${A}` },
	{ name: "skill block alone, both", text: block, prepends: [P], appends: [A], want: `${block}\n\n${P}\n\n${A}` },
];

for (const c of cases) {
	test(c.name, () => assert.equal(composeMessage(c), c.want));
}

test("slashName reads the name the way Pi reads a template name", () => {
	assert.equal(slashName("/review src/a.ts"), "review");
	assert.equal(slashName("/review\nmore"), "review");
	assert.equal(slashName("/review"), "review");
	assert.equal(slashName("hi /review"), undefined);
	assert.equal(slashName("/"), undefined);
});
