import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { promisify } from "node:util";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const exec = promisify(execFile);
const template = [
  'change_id.shortest(8)',
  'bookmarks',
  'if(empty, "empty", "modified")',
  'if(conflict, "conflict", "")',
].join(' ++ "\\n" ++ ');
const singleLine = (text) => text.replace(/[\x00-\x1f\x7f-\x9f]/g, " ");
const formatTokens = (n) => n < 1000 ? String(n) : `${(n / 1000).toFixed(1)}k`;

/** @param {import("@earendil-works/pi-coding-agent").ExtensionAPI} pi */
export default function (pi) {
  let dispose;

  pi.on("session_start", (_event, ctx) => {
    dispose?.();
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      let status = "";
      let pending = false;
      let stopped = false;
      const controller = new AbortController();

      // Never run a subprocess in render(). Polling also catches external jj edits.
      const refresh = async () => {
        if (pending || stopped) return;
        pending = true;
        let next = "";
        try {
          const { stdout } = await exec("jj", [
            "log", "--ignore-working-copy", "--no-graph", "--color", "never", "-r", "@", "-T", template,
          ], { cwd: ctx.cwd, timeout: 2500, maxBuffer: 64 * 1024, signal: controller.signal });
          const [change, bookmarks, state, conflict] = stdout.trimEnd().split("\n");
          if (change) {
            next = `jj ${singleLine(change)}`;
            if (bookmarks) next += ` ${singleLine(bookmarks)}`;
            next += state === "modified" ? " *" : " (empty)";
            if (conflict === "conflict") next += " !conflict";
          }
        } catch {
          // No jj executable, no workspace, timeout, or transient repository error.
          // Clear stale metadata; do not fall back to a misleading git branch.
        } finally {
          pending = false;
        }
        if (!stopped && next !== status) {
          status = next;
          tui.requestRender();
        }
      };

      const timer = setInterval(() => void refresh(), 3000);
      timer.unref?.();
      void refresh();
      const cleanup = () => {
        if (stopped) return;
        stopped = true;
        clearInterval(timer);
        controller.abort();
      };
      dispose = cleanup;

      return {
        dispose: cleanup,
        invalidate() {},
        render(width) {
          const home = homedir();
          const cwd = ctx.cwd === home ? "~" : ctx.cwd.startsWith(`${home}/`) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;
          const name = ctx.sessionManager.getSessionName();
          const location = `${singleLine(cwd)}${status ? ` (${status})` : ""}${name ? ` • ${singleLine(name)}` : ""}`;

          let input = 0, output = 0, cacheRead = 0, cacheWrite = 0, cost = 0;
          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type !== "message" || entry.message.role !== "assistant") continue;
            const usage = entry.message.usage;
            input += usage.input;
            output += usage.output;
            cacheRead += usage.cacheRead;
            cacheWrite += usage.cacheWrite;
            cost += usage.cost.total;
          }
          const stats = [`↑${formatTokens(input)}`, `↓${formatTokens(output)}`];
          if (cacheRead) stats.push(`R${formatTokens(cacheRead)}`);
          if (cacheWrite) stats.push(`W${formatTokens(cacheWrite)}`);
          stats.push(`$${cost.toFixed(3)}`);
          const context = ctx.getContextUsage();
          if (context?.percent != null) stats.push(`${context.percent.toFixed(1)}%`);
          const left = stats.join(" ");
          const thinking = pi.getThinkingLevel();
          const right = `${ctx.model?.id ?? "no-model"}${thinking && thinking !== "off" ? ` • ${thinking}` : ""}`;
          const padding = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
          const lines = [
            theme.fg("dim", truncateToWidth(location, width)),
            theme.fg("dim", truncateToWidth(left + padding + right, width)),
          ];
          const statuses = [...footerData.getExtensionStatuses().entries()]
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, text]) => text.replace(/[\r\n]/g, " "));
          if (statuses.length) lines.push(truncateToWidth(statuses.join(" "), width));
          return lines;
        },
      };
    });
  });

  pi.on("session_shutdown", () => {
    dispose?.();
    dispose = undefined;
  });
}
