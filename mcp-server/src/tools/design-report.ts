import { z } from "zod";
import { runR } from "../r-bridge.js";

export const toolName = "design_report";
export const schema = {
  result: z
    .record(z.unknown())
    .describe(
      "A designr result object as returned by any design_* tool (the JSON payload, " +
      "including $method, $inputs, and (for GS) $boundaries / $timing)."
    ),
  format: z
    .enum(["markdown", "text"])
    .optional()
    .describe("Output format. Currently only 'markdown' is implemented; 'text' is reserved."),
};

export const description =
  "Render a clinician-readable summary of any designr result. Produces a markdown document " +
  "with sections: Design overview, Key inputs, Headline output, Analysis plan (when GS " +
  "boundaries / timing are present), and Method & version. Suitable to paste into a SAP-style " +
  "document or render to HTML / PDF / Word downstream.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
