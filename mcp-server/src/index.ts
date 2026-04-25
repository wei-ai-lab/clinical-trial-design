#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

import * as fixedBinary from "./tools/fixed-binary.js";
import * as fixedContinuous from "./tools/fixed-continuous.js";
import * as fixedSurvivalPh from "./tools/fixed-survival-ph.js";
import * as fixedSurvivalMaxcombo from "./tools/fixed-survival-maxcombo.js";
import * as fixedSurvivalRmst from "./tools/fixed-survival-rmst.js";
import * as fixedSurvivalMilestone from "./tools/fixed-survival-milestone.js";
import * as gsBinary from "./tools/gs-binary.js";
import * as gsContinuous from "./tools/gs-continuous.js";
import * as gsSurvivalPh from "./tools/gs-survival-ph.js";
import * as gsSurvivalNphCombo from "./tools/gs-survival-nph-combo.js";
import * as validateBenchmark from "./tools/validate-benchmark.js";
import * as verifyDesign from "./tools/verify-design.js";
import * as designReport from "./tools/design-report.js";
import { DesignrToolError } from "./r-bridge.js";

const tools = [
  fixedBinary,
  fixedContinuous,
  fixedSurvivalPh,
  fixedSurvivalMaxcombo,
  fixedSurvivalRmst,
  fixedSurvivalMilestone,
  gsBinary,
  gsContinuous,
  gsSurvivalPh,
  gsSurvivalNphCombo,
  validateBenchmark,
  verifyDesign,
  designReport,
];

type ToolMod = {
  toolName: string;
  description: string;
  schema: Record<string, unknown>;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  handler: (args: any) => Promise<unknown>;
};

async function main() {
  const server = new McpServer({
    name: "designr",
    version: "0.0.2",
  });

  for (const mod of tools as unknown as ToolMod[]) {
    server.registerTool(
      mod.toolName,
      {
        description: mod.description,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        inputSchema: mod.schema as any,
      },
      async (args: Record<string, unknown>) => {
        try {
          const result = await mod.handler(args);
          return {
            content: [
              {
                type: "text" as const,
                text: JSON.stringify(result, null, 2),
              },
            ],
          };
        } catch (e) {
          if (e instanceof DesignrToolError) {
            return {
              isError: true,
              content: [
                {
                  type: "text" as const,
                  text:
                    `designr error [${e.cls}]` +
                    (e.field ? ` on field '${e.field}'` : "") +
                    `: ${e.message}`,
                },
              ],
            };
          }
          const msg = e instanceof Error ? e.message : String(e);
          return {
            isError: true,
            content: [{ type: "text" as const, text: `internal error: ${msg}` }],
          };
        }
      }
    );
  }

  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("fatal:", err);
  process.exit(1);
});
