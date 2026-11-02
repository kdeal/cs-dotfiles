import assert from "node:assert/strict";
import { EventEmitter } from "node:events";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import * as os from "node:os";
import * as path from "node:path";
import { Readable } from "node:stream";
import test from "node:test";
import { pathToFileURL } from "node:url";

// Exercise the real tool and its subprocess parser without Pi's bundled modules.
test("forwards child message lifecycles in single, parallel, and chain modes", async () => {
	const dir = await mkdtemp(path.join(os.tmpdir(), "subagent-stream-test-"));
	try {
		let source = await readFile(new URL("../subagent/index.ts", import.meta.url), "utf8");
		source = source.replace(/^import [^;]+ from "(?:@earendil-works\/[^"\n]+|typebox|\.\/agents\.ts)";\n/gm, "");
		source = source.replace('import { spawn } from "node:child_process";', "const spawn = globalThis.subagentStreamTest.spawn;");
		source = `
const Type = new Proxy({}, { get: () => (...args) => ({}) });
const StringEnum = () => ({});
const CONFIG_DIR_NAME = ".pi";
const getAgentDir = () => "/agents";
const discoverAgents = () => ({ agents: [{ name: "worker", source: "user", systemPrompt: "" }], projectAgentsDir: null });
${source}`;
		const file = path.join(dir, "extension.ts");
		await writeFile(file, source);

		const events = [
			{ type: "message_start", message: { role: "assistant", content: [] } },
			{ type: "message_update", assistantMessageEvent: { type: "thinking_delta", contentIndex: 0, delta: "Thinking" } },
			{ type: "message_update", assistantMessageEvent: { type: "text_delta", contentIndex: 1, delta: "Hello\u2028world" } },
			{ type: "message_update", assistantMessageEvent: { type: "toolcall_delta", contentIndex: 2, delta: '{"command":' } },
			{ type: "message_end", message: { role: "assistant", content: [{ type: "text", text: "Hello world" }] } },
			{ type: "message_start", message: { role: "toolResult", content: [] } },
			{ type: "message_end", message: { role: "toolResult", content: [{ type: "text", text: "Done" }] } },
		];
		(globalThis as any).subagentStreamTest = {
			spawn: () => {
				const proc = new EventEmitter() as any;
				proc.stdout = new Readable({ read() {} });
				proc.stderr = new EventEmitter();
				proc.stdout.once("end", () => proc.emit("close", 0));
				queueMicrotask(() => {
					const data = Buffer.from(events.map((event) => JSON.stringify(event)).join("\n"));
					// Split inside U+2028's UTF-8 bytes and leave the final line without LF.
					const split = data.indexOf(Buffer.from("\u2028")) + 1;
					proc.stdout.push(data.subarray(0, split));
					proc.stdout.push(data.subarray(split));
					proc.stdout.push(null);
				});
				return proc;
			},
		};
		const { default: extension } = await import(pathToFileURL(file).href);
		let tool: any;
		extension({ registerTool: (value: any) => { tool = value; } });
		const task = { agent: "worker", task: "Do work" };
		for (const [mode, params, count] of [
			["single", task, 1],
			["parallel", { tasks: [task, task] }, 2],
			["chain", { chain: [task, task] }, 2],
		] as const) {
			const updates: any[] = [];
			const result = await tool.execute("call", params, undefined,
				(update: any) => updates.push(structuredClone(update)),
				{ cwd: dir, hasUI: false });
			const streamed = updates.filter((update) => update.details.stream);
			assert.equal(streamed.length, events.length * count, mode);
			for (let index = 0; index < count; index++) {
				assert.deepEqual(streamed.filter((update) => update.details.stream.index === index)
					.map((update) => update.details.stream.event), events, `${mode} child ${index}`);
			}
			assert.equal(result.details.stream, undefined, "stream events are transient");
			assert.equal(result.details.results.length, count);
			for (const child of result.details.results) {
				assert.deepEqual(child.messages, [events[4].message, events[6].message]);
				assert.equal(child.usage.turns, 1, "deltas do not inflate turn usage");
			}
		}
	} finally {
		delete (globalThis as any).subagentStreamTest;
		await rm(dir, { recursive: true, force: true });
	}
});
