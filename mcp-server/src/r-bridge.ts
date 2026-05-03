import { spawn, spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { existsSync, readdirSync, statSync } from "node:fs";

const DEFAULT_TIMEOUT_MS = 60_000;

// Common Rscript install locations checked when DESIGNR_RSCRIPT isn't
// set and `Rscript` isn't on PATH. Covers:
//   - Posit Workbench (managed R installs at /opt/R/<version>/bin/)
//   - Linux distros (Debian/Ubuntu /usr/bin/, RHEL /usr/lib64/R/bin/)
//   - Homebrew on macOS (/opt/homebrew/bin/, /usr/local/bin/)
//   - rig-managed installs (~/.rig/, /opt/R/)
// Resolved at module load — cheap, deterministic, no IO during runR().
const FALLBACK_RSCRIPT_DIRS = [
  "/opt/R",                  // Posit Workbench / RStudio Server / rig
  "/usr/local/lib/R/bin",
  "/usr/lib/R/bin",
  "/usr/lib64/R/bin",
  "/usr/local/bin",
  "/usr/bin",
  "/opt/homebrew/bin",
  "/Library/Frameworks/R.framework/Resources/bin",  // macOS CRAN install
];

/**
 * Discover an Rscript binary when neither DESIGNR_RSCRIPT nor PATH
 * resolves. Returns the first existing Rscript path or null.
 *
 * For /opt/R, walks immediate subdirectories (the R version tree:
 * /opt/R/4.5.1/, /opt/R/4.4.0/, etc.) and prefers the lexicographically
 * latest one — typically the newest installed version.
 */
function discoverRscript(): string | null {
  // First: does `which Rscript` work? If so, that's the canonical path.
  try {
    const which = spawnSync("which", ["Rscript"], { encoding: "utf8" });
    if (which.status === 0) {
      const found = which.stdout.trim().split("\n")[0];
      if (found && existsSync(found)) return found;
    }
  } catch {
    // `which` not present — fall through to dir walk.
  }

  // Second: walk the FALLBACK_RSCRIPT_DIRS list.
  for (const dir of FALLBACK_RSCRIPT_DIRS) {
    if (!existsSync(dir)) continue;
    try {
      const direct = `${dir}/Rscript`;
      if (existsSync(direct) && statSync(direct).isFile()) return direct;
      // /opt/R-style version subdirs:
      const entries = readdirSync(dir).sort().reverse();   // latest first
      for (const ver of entries) {
        const candidate = `${dir}/${ver}/bin/Rscript`;
        if (existsSync(candidate)) return candidate;
      }
    } catch {
      // Permission error or bad path — skip this dir.
    }
  }
  return null;
}

const DISCOVERED_RSCRIPT = discoverRscript();

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
  // Resolution order:
  //   1. opts.rscript               — explicit override (test fixtures)
  //   2. DESIGNR_RSCRIPT env var    — user-supplied path
  //   3. DISCOVERED_RSCRIPT          — auto-discovered at module load
  //   4. "Rscript"                   — last-resort PATH lookup
  const rscript =
    opts.rscript ??
    process.env.DESIGNR_RSCRIPT ??
    DISCOVERED_RSCRIPT ??
    "Rscript";
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
            `Failed to spawn Rscript at '${rscript}' (launcher '${launcher}'): ${err.message}.\n\n` +
            `If R is installed but Claude Code can't see it, the most likely cause is that ` +
            `Claude Code's MCP subprocess doesn't inherit your shell's environment. ` +
            `Set DESIGNR_RSCRIPT in Claude Code's settings (NOT just your shell):\n\n` +
            `  ~/.claude/settings.json:\n` +
            `    {\n` +
            `      "env": { "DESIGNR_RSCRIPT": "/opt/R/4.5.1/bin/Rscript" }\n` +
            `    }\n\n` +
            `Or set DESIGNR_LAUNCHER to override the launcher path. Auto-discovery checked: ` +
            (DISCOVERED_RSCRIPT
              ? `${DISCOVERED_RSCRIPT} (found but spawn failed — permissions?)`
              : `nothing in /opt/R, /usr/local/lib/R/bin, /usr/lib/R/bin, /usr/lib64/R/bin, /usr/local/bin, /usr/bin, /opt/homebrew/bin, /Library/Frameworks/R.framework`) +
            `.`,
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
