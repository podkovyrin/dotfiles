import { parseSkillBlock } from "@earendil-works/pi-coding-agent";

const SKILL_COMMAND = "/skill:";

const paragraphs = (parts: string[]) => parts.join("\n\n");

/**
 * Put snippet bodies around the typed text, a blank line between paragraphs.
 *
 * Pi expands `/skill:<name>` only at the start of the text, so a `/skill:`
 * command stays first and the snippets go around its arguments. A leading
 * `<skill>` block that another extension already wrote stays first too.
 */
export function composeMessage({
	text,
	prepends,
	appends,
}: {
	text: string;
	prepends: string[];
	appends: string[];
}): string {
	if (text.startsWith(SKILL_COMMAND)) {
		// Split the way Pi's `_expandSkillCommand` does.
		const space = text.indexOf(" ");
		const command = space === -1 ? text : text.slice(0, space);
		const args = space === -1 ? "" : text.slice(space + 1).trim();
		return `${command} ${paragraphs([...prepends, ...(args ? [args] : []), ...appends])}`;
	}

	const skill = parseSkillBlock(text);
	if (skill) {
		const block = `<skill name="${skill.name}" location="${skill.location}">\n${skill.content}\n</skill>`;
		const rest = text.slice(block.length).replace(/^\n\n/, "");
		return paragraphs([block, ...prepends, ...(rest ? [rest] : []), ...appends]);
	}

	return paragraphs([...prepends, text, ...appends]);
}

/**
 * The name `/<name> ...` names, the way Pi's `expandPromptTemplate` reads it.
 * Pi splits all text after the name into shell-style words and joins them
 * with spaces into `$ARGUMENTS`, so snippets cannot go into a template's
 * arguments without being changed.
 */
export function slashName(text: string): string | undefined {
	return text.match(/^\/([^\s]+)(?:\s+[\s\S]*)?$/)?.[1];
}
