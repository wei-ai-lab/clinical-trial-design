import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { existsSync } from "node:fs";

const DEFAULT_TIMEOUT_MS = 60_000;

// Path to the bundled R launcher that sources ClinicalTrialDesign/R/*.R
// in-place, avoiding the need for
// `remotes::install_local("r-package/ClinicalTrialDesign")` on every
// install. Two layouts are supported automatically:
//
//   1. npm-published layout — `npm install clinical-trial-design`
//      lands the bundle at `<prefix>/lib/node_modules/clinical-trial-design/dist/index.js`
//      with the staged R sources at `<prefix>/lib/.../clinical-trial-design/r/inst/launcher.R`.
//      `prepublishOnly` (see package.json) runs `stage-r` to copy them in.
//
//   2. in-repo layout — running from a git clone, the bundle is at
//      `<repo>/mcp-server/dist/index.js` and the R sources live at
//      `<repo>/r-package/ClinicalTrialDesign/inst/launcher.R`.
//
// Resolution order: env var DESIGNR_LAUNCHER -> bundled (1) -> repo (2).
const HERE = dirname(fileURLToPath(import.meta.url));
const BUNDLED_LAUNCHER = resolve(HERE, "..", "r", "inst", "launcher.R");
const REPO_LAUNCHER = resolve(
  HERE,
  "..",
  "..",
  "r-package",
  "ClinicalTrialDesign",
  "inst",
  "launcher.R"
);
const DEFAULT_LAUNCHER = existsSync(BUNDLED_LAUNCHER)
  ? BUNDLED_LAUNCHER
  : REPO_LAUNCHER;

export interface DesignrError {
  class: string;
  message: string;
  field?: string;
}

export class DesignrToolError extends Error {
  public readonly cls: string;
  public readonly field?: string;
  constructor(err: DesignrError) {
    super(err.message);
    this.name = "DesignrToolError";
    this.cls = err.class;
    this.field = err.field;
  }
}

export interface RunROptions {
  timeoutMs?: number;
  rscript?: string;
  launcher?: string;
}

/**
 * Spawn a fresh Rscript subprocess, pipe `{tool, args}` JSON in via stdin,
 * parse the single-line JSON response on stdout. Fully stateless — one
 * process per call, ~300 ms overhead per invocation.
 */
export async function runR(
  tool: string,
  args: Record<string, unknown>,
  opts: RunROptions = {}
): Promise<Record<string, unknown>> {
  const rscript = opts.rscript ?? process.env.DESIGNR_RSCRIPT ?? "Rscript";
  const launcher =
    opts.launcher ?? process.env.DESIGNR_LAUNCHER ?? DEFAULT_LAUNCHER;
  const timeoutMs = opts.timeoutMs ?? DEFAULT_TIMEOUT_MS;
  const payload = JSON.stringify({ tool, args });

  return new Promise((resolvePromise, reject) => {
    // Note: do NOT pass --vanilla. It implies --no-environ, which strips
    // R_LIBS_USER and prevents the launcher from finding CRAN deps
    // (gsDesign, gsDesign2, jsonlite) that live in the user's library.
    // Rscript's defaults (--no-save --no-restore) already give us a
    // clean session without breaking dep resolution.
    const child = spawn(rscript, [launcher], {
      stdio: ["pipe", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    let settled = false;

    const timer = setTimeout(() => {
      if (settled) return;
      settled = true;
      child.kill("SIGKILL");
      reject(
        new DesignrToolError({
          class: "timeout",
          message: `designr R tool '${tool}' exceeded ${timeoutMs}ms`,
        })
      );
    }, timeoutMs);

    child.stdout.on("data", (b) => (stdout += b.toString()));
    child.stderr.on("data", (b) => (stderr += b.toString()));

    child.on("error", (err) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      reject(
        new DesignrToolError({
          class: "rscript_spawn_failed",
          message:
            `Failed to spawn Rscript at '${rscript}' (launcher '${launcher}'): ${err.message}. ` +
            `Set DESIGNR_RSCRIPT to the full Rscript path or DESIGNR_LAUNCHER to override the launcher.`,
        })
      );
    });

    child.on("close", (code) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      if (code !== 0 && !stdout.trim()) {
        reject(
          new DesignrToolError({
            class: "r_crash",
            message: `Rscript exited ${code}: ${stderr.trim() || "(no stderr)"}`,
          })
        );
        return;
      }
      const line = stdout.trim().split("\n").pop() ?? "";
      let parsed: {
        ok: boolean;
        result?: Record<string, unknown>;
        error?: DesignrError;
      };
      try {
        parsed = JSON.parse(line);
      } catch (e) {
        reject(
          new DesignrToolError({
            class: "r_bad_json",
            message: `Could not parse R output as JSON: ${line.slice(0, 200)}`,
          })
        );
        return;
      }
      if (parsed.ok && parsed.result !== undefined) {
        resolvePromise(parsed.result);
      } else if (parsed.error) {
        reject(new DesignrToolError(parsed.error));
      } else {
        reject(
          new DesignrToolError({
            class: "r_malformed_response",
            message: `Unexpected R response shape: ${line.slice(0, 200)}`,
          })
        );
      }
    });

    child.stdin.write(payload);
    child.stdin.end();
  });
}
