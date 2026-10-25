import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

// Load without Pi's bundled modules and control subprocess/timer completion.
const source = (await readFile(new URL("../jj-footer.js", import.meta.url), "utf8"))
  .replace('import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";',
    'const truncateToWidth = (s, w) => s.slice(0, w); const visibleWidth = (s) => s.length;')
  .replace('const exec = promisify(execFile);', 'const exec = (...args) => globalThis.footerTest.exec(...args);')
  .replace('const timer = setInterval(() => void refresh(), 3000);',
    'const timer = { unref() {} }; globalThis.footerTest.refresh = refresh;')
  .replace('clearInterval(timer);', 'globalThis.footerTest.cleared = true;');
const { default: extension } = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`);

const tick = () => new Promise((resolve) => setImmediate(resolve));

test("jj footer status, refresh, layout, and lifecycle", async () => {
  let result = "abcd1234\nmain\nmodified\nconflict";
  let calls = 0;
  globalThis.footerTest = {
    exec: async (command, args, options) => {
      calls++;
      assert.equal(command, "jj");
      assert.equal(options.cwd, "/workspace");
      assert.ok(args.includes("--no-graph"));
      if (result instanceof Error) throw result;
      return { stdout: result };
    },
  };
  const events = new Map();
  let footer;
  let renders = 0;
  const ctx = {
    mode: "tui", cwd: "/workspace", model: { id: "test-model" },
    getContextUsage: () => ({ percent: 12.5 }),
    sessionManager: {
      getSessionName: () => "test-session",
      getBranch: () => [{ type: "message", message: { role: "assistant", usage: {
        input: 1200, output: 200, cacheRead: 300, cacheWrite: 0, cost: { total: 0.123 },
      } } }],
    },
    ui: { setFooter: (factory) => {
      footer = factory({ requestRender: () => renders++ }, { fg: (_color, text) => text }, {
        getExtensionStatuses: () => new Map([["other", "extension status"]]),
      });
    } },
  };
  extension({ on: (name, handler) => events.set(name, handler), getThinkingLevel: () => "medium" });
  events.get("session_start")({}, ctx);
  await tick();
  assert.match(footer.render(140)[0], /jj abcd1234 main \* !conflict/);
  assert.match(footer.render(140)[1], /↑1.2k ↓200 R300 \$0.123 12.5%/);
  assert.match(footer.render(140)[1], /test-model • medium/);
  assert.equal(footer.render(140)[2], "extension status");
  for (const width of [0, 1, 10, 40]) {
    assert.ok(footer.render(width).every((line) => line.length <= width));
  }
  result = "efgh5678\n\nempty\n";
  await globalThis.footerTest.refresh();
  assert.match(footer.render(140)[0], /jj efgh5678 \(empty\)/);
  assert.doesNotMatch(footer.render(140)[0], /main|conflict|\*/);
  result = new Error("not a jj repository / executable missing");
  await globalThis.footerTest.refresh();
  assert.doesNotMatch(footer.render(140)[0], /jj /);
  assert.equal(renders, 3);
  events.get("session_shutdown")();
  footer.dispose(); // Cleanup is idempotent.
  assert.equal(globalThis.footerTest.cleared, true);
  const before = calls;
  await globalThis.footerTest.refresh();
  assert.equal(calls, before);
  events.get("session_start")({}, { mode: "print" });
  assert.equal(calls, before);
});
