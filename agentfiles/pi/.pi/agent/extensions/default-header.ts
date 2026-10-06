import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	let cleanup: (() => void) | undefined;

	const install = (ctx: ExtensionContext) => {
		if (!ctx.hasUI || ctx.mode !== "tui") return;
		cleanup?.();

		// Extension contexts share this UI object. Keep the native header even
		// when another extension installs a header later in startup.
		const ui = ctx.ui;
		const original = ui.setHeader;
		const nativeOnly: typeof ui.setHeader = () => original.call(ui, undefined);
		ui.setHeader = nativeOnly;
		nativeOnly(undefined);

		cleanup = () => {
			if (ui.setHeader === nativeOnly) ui.setHeader = original;
			cleanup = undefined;
		};
	};

	pi.on("session_start", (_event, ctx) => install(ctx));
	pi.on("session_shutdown", () => cleanup?.());

	pi.registerCommand("default-header", {
		description: "Keep the default Pi header",
		handler: async (_args, ctx) => install(ctx),
	});
}
