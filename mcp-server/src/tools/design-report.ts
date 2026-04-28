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
    .enum(["markdown", "text", "docx", "pdf"])
    .optional()
    .describe(
      "Output format. 'markdown' (default) returns the report as text. " +
        "'docx' writes a native Word document via the officer R package; " +
        "'pdf' renders via rmarkdown + Pandoc (requires Pandoc + a TeX " +
        "engine on the system PATH). 'docx' / 'pdf' return the path of the " +
        "file written."
    ),
  path: z
    .string()
    .optional()
    .describe(
      "For format='docx' or 'pdf': output file path. If omitted, a tempfile " +
        "is created and its path returned in the result."
    ),
};

export const description =
  "Render a clinician-readable design summary in markdown, Word, or PDF. " +
  "Reasoning chain (when populated on the result) appears as a table; " +
  "sponsor_confidential entries trigger a redaction warning at the top. " +
  "Sections: title, design overview, key inputs, headline output, GS " +
  "analysis plan, reasoning chain, method + version. Default output is " +
  "markdown text; format='docx' returns a native Word file path " +
  "(officer); format='pdf' renders via rmarkdown + Pandoc.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
