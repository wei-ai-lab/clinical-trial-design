#' Render a ClinicalTrialDesign result as markdown, Word, or PDF
#'
#' Produces a clinician-readable report from the JSON-shaped result returned
#' by any `design_*` tool. Markdown output is in-memory text; `docx` and
#' `pdf` write to a path on disk and return that path.
#'
#' Sections rendered (presence depends on result type):
#' \itemize{
#'   \item Title (family + comparison)
#'   \item Sponsor-confidential warning (if `reasoning_chain` includes any
#'     entry with `source_type = "sponsor_confidential"`)
#'   \item Design overview (family, comparison, sided, allocation, GS axes)
#'   \item Key inputs (only inputs that are populated)
#'   \item Headline output (sample size, per-arm, events)
#'   \item Analysis plan (boundaries + timing for GS designs)
#'   \item Reasoning chain (decision/value/justification/source/reference)
#'   \item Method + version (tool method, backend version, package version)
#' }
#'
#' @param result A `ClinicalTrialDesign` result list (the `$result` payload
#'   returned by the MCP bridge).
#' @param format Output format: `"markdown"` (default), `"text"` (alias),
#'   `"docx"` (Word), `"pdf"`.
#' @param path Output file path for `docx` / `pdf`. If `NULL`, a tempfile
#'   is created and its path returned.
#'
#' @return For `markdown`/`text`: a length-1 character vector holding the
#'   formatted report. For `docx`/`pdf`: the path of the file written
#'   (length-1 character).
#'
#' @details
#' \itemize{
#'   \item `docx` requires the `officer` package (Suggests). The whole
#'     report is rendered as native Word paragraphs, headings, and tables —
#'     not by piping markdown through Pandoc. This means no Pandoc system
#'     dependency for the Word path.
#'   \item `pdf` renders the markdown via `rmarkdown::render(...,
#'     output_format = "pdf_document")`. Requires Pandoc + a TeX
#'     engine. If either is missing the function falls back to writing
#'     the markdown source and emits a clear message rather than failing
#'     silently.
#' }
#'
#' @export
design_report <- function(result,
                          format = c("markdown", "text", "docx", "pdf"),
                          path   = NULL) {
  if (!is.list(result) || is.null(result$method) || is.null(result$inputs)) {
    designr_stop("result", "must be a ClinicalTrialDesign result list with $method and $inputs")
  }
  format <- match.arg(format)

  # docx and pdf are renderer dispatchers — both build the markdown body
  # then render. Hand off and return.
  if (format == "docx") {
    return(.render_docx(result, path))
  }
  if (format == "pdf") {
    return(.render_pdf(result, path))
  }

  fam <- .report_family(result$method)
  inp <- result$inputs

  lines <- character(0)
  lines <- c(lines, sprintf("# %s", .report_title(fam, inp)), "")

  # Sponsor-confidential redaction warning at the top — surfaces clearly
  # before the user copies the report into a deck or sends it externally.
  if (reasoning_has_confidential(result$reasoning_chain)) {
    lines <- c(lines,
               "> ⚠️ **Sponsor-confidential content.** This design's",
               "> reasoning chain contains entries tagged",
               "> `source_type: sponsor_confidential`. Review and redact",
               "> before sharing externally.",
               "")
  }

  lines <- c(lines,
             "## Design overview", "",
             .report_overview(fam, inp),
             "",
             "## Key inputs", "",
             .report_inputs(fam, inp),
             "",
             "## Headline output", "",
             .report_output(result),
             "")
  if (!is.null(result$boundaries) || !is.null(result$timing)) {
    lines <- c(lines,
               "## Analysis plan", "",
               .report_analysis_plan(result),
               "")
  }
  if (!is.null(result$reasoning_chain) && length(result$reasoning_chain) > 0L) {
    lines <- c(lines,
               "## Reasoning chain", "",
               .report_reasoning(result$reasoning_chain),
               "")
  }
  lines <- c(lines,
             "## Method & version", "",
             sprintf("- **Method:** `%s`", result$method),
             sprintf("- **Backend version:** `%s`", result$package_version %||% "n/a"),
             sprintf("- **ClinicalTrialDesign version:** `%s`",
                     tryCatch(as.character(utils::packageVersion("ClinicalTrialDesign")),
                              error = function(e) "loaded")))
  paste(lines, collapse = "\n")
}

# Render the reasoning chain as a markdown table. Each row: decision,
# value, justification, source_type (with the sponsor_confidential tag
# rendered emphatically), source_ref. Long justifications are kept in
# place — markdown tables don't paginate, but the table is readable in
# both a rendered viewer and as plain text.
.report_reasoning <- function(rc) {
  if (is.null(rc) || length(rc) == 0L) return("_(empty)_")
  src_label <- function(st) {
    if (identical(st, "sponsor_confidential"))
      return("`sponsor_confidential` ⚠️")
    sprintf("`%s`", st)
  }
  fmt_value <- function(v) {
    if (is.null(v)) return("—")
    if (is.numeric(v)) return(sprintf("%g", v))
    if (is.logical(v)) return(if (v) "true" else "false")
    as.character(v)
  }
  rows <- vapply(rc, function(e) {
    sprintf("| %s | %s | %s | %s | %s |",
            e$decision,
            fmt_value(e$value),
            e$justification,
            src_label(e$source_type),
            if (is.null(e$source_ref)) "—" else e$source_ref)
  }, character(1))
  c("| Decision | Value | Justification | Source | Reference |",
    "|---|---|---|---|---|",
    rows)
}

.report_family <- function(method) {
  if (grepl("nBinomial",                    method, fixed = TRUE)) return("fixed_binary")
  if (grepl("nNormal",                      method, fixed = TRUE)) return("fixed_continuous")
  if (grepl("nSurv",                        method, fixed = TRUE)) return("fixed_survival_ph")
  if (grepl("gsSurv",                       method, fixed = TRUE)) return("gs_survival_ph")
  if (grepl("gsDesign (binary",             method, fixed = TRUE)) return("gs_binary")
  if (grepl("gsDesign (continuous",         method, fixed = TRUE)) return("gs_continuous")
  if (grepl("fixed_design_maxcombo",        method, fixed = TRUE)) return("fixed_survival_maxcombo")
  if (grepl("fixed_design_rmst",            method, fixed = TRUE)) return("fixed_survival_rmst")
  if (grepl("fixed_design_milestone",       method, fixed = TRUE)) return("fixed_survival_milestone")
  if (grepl("gs_design_combo|gs_design_wlr|gs_design_ahr", method)) return("gs_survival_nph_combo")
  "unknown"
}

.report_title <- function(family, inp) {
  comp <- inp$comparison %||% "superiority"
  pretty_fam <- switch(family,
    fixed_binary              = "Fixed-sample binary endpoint",
    fixed_continuous          = "Fixed-sample continuous endpoint",
    fixed_survival_ph         = "Fixed-sample time-to-event (PH log-rank)",
    fixed_survival_maxcombo   = "Fixed-sample time-to-event (MaxCombo, NPH)",
    fixed_survival_rmst       = "Fixed-sample time-to-event (RMST)",
    fixed_survival_milestone  = "Fixed-sample time-to-event (milestone survival)",
    gs_binary                 = "Group-sequential binary endpoint",
    gs_continuous             = "Group-sequential continuous endpoint",
    gs_survival_ph            = "Group-sequential time-to-event (PH log-rank)",
    gs_survival_nph_combo     = "Group-sequential time-to-event (NPH)",
    "ClinicalTrialDesign result")
  sprintf("%s \u2014 %s", pretty_fam, comp)
}

.report_overview <- function(family, inp) {
  comp <- inp$comparison %||% "superiority"
  rows <- c(
    sprintf("- **Family:** `%s`", family),
    sprintf("- **Comparison:** %s", comp),
    sprintf("- **Sided:** %s", inp$sided %||% "\u2014"),
    sprintf("- **Allocation ratio (T:C):** %s",
            inp$allocation_ratio %||% 1)
  )
  if (!is.null(inp$k))      rows <- c(rows, sprintf("- **Analyses (k):** %d", inp$k))
  if (!is.null(inp$sfu))    rows <- c(rows, sprintf("- **Upper spending:** `%s`", inp$sfu))
  if (!is.null(inp$sfl))    rows <- c(rows, sprintf("- **Lower spending:** `%s`", inp$sfl))
  if (!is.null(inp$test.type))
    rows <- c(rows, sprintf("- **gsDesign test.type:** %d", inp$test.type))
  paste(rows, collapse = "\n")
}

.report_inputs <- function(family, inp) {
  show <- function(label, val, fmt = "%s") {
    if (is.null(val) || (is.atomic(val) && all(is.na(val)))) return(NULL)
    sprintf("- **%s:** %s", label, sprintf(fmt, val))
  }
  rows <- c(
    show("Alpha", inp$alpha,  "%.4f"),
    show("Power", inp$power,  "%.3f"),
    show("Control event rate",   inp$p_control,    "%.3f"),
    show("Treatment event rate", inp$p_treatment,  "%.3f"),
    show("Mean difference",      inp$mean_diff,    "%.3f"),
    show("Common SD",            inp$sd,           "%.3f"),
    show("Control median (months)", inp$control_median, "%.2f"),
    show("Hazard ratio (target)",   inp$hazard_ratio,    "%.3f"),
    show("HR null (margin)",         inp$hr_null,         "%.3f"),
    show("Accrual duration (months)", inp$accrual_duration, "%.1f"),
    show("Follow-up after last enroll (months)", inp$followup_duration, "%.1f"),
    show("Accrual rate (subjects/month)", inp$accrual_rate, "%.1f"),
    show("Dropout rate (per month)", inp$dropout_rate, "%.4f"),
    show("Non-inferiority margin", inp$ni_margin, "%.4f"),
    show("Equivalence margin",      inp$equiv_margin, "%.4f"),
    show("Delay (months)",  inp$delay_months, "%.2f"),
    show("Post-delay HR",   inp$post_delay_hr, "%.3f"),
    show("RMST \u03c4 (months)", inp$tau, "%.2f"),
    show("Study duration (months)", inp$study_duration, "%.1f")
  )
  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0) "_(no inputs)_" else paste(rows, collapse = "\n")
}

.report_output <- function(result) {
  rows <- c(sprintf("- **Total sample size:** %s", result$sample_size_total))
  if (!is.null(result$sample_size_per_arm)) {
    pa <- result$sample_size_per_arm
    nm <- names(pa)
    if (is.null(nm) || all(nm == "")) nm <- paste0("arm", seq_along(pa))
    parts <- vapply(seq_along(pa),
                    function(i) sprintf("%s = %s", nm[i], pa[i]),
                    character(1))
    rows <- c(rows, sprintf("- **Per-arm:** %s", paste(parts, collapse = ", ")))
  }
  if (!is.null(result$events_total)) {
    rows <- c(rows, sprintf("- **Total events:** %s", result$events_total))
  }
  paste(rows, collapse = "\n")
}

.report_analysis_plan <- function(result) {
  rows <- character(0)
  b <- result$boundaries
  t <- result$timing
  if (!is.null(b) && !is.null(b$upper_z)) {
    K <- length(b$upper_z)
    z <- vapply(b$upper_z, function(x) sprintf("%.3f", x), character(1))
    rows <- c(rows, sprintf("- **Upper Z-boundaries:** %s",
                            paste(z, collapse = ", ")))
    if (!is.null(b$upper_p)) {
      p <- vapply(b$upper_p, function(x) sprintf("%.4f", x), character(1))
      rows <- c(rows, sprintf("- **One-sided p-boundaries:** %s",
                              paste(p, collapse = ", ")))
    }
    if (!is.null(b$lower_z)) {
      lz <- vapply(b$lower_z, function(x) sprintf("%.3f", x), character(1))
      rows <- c(rows, sprintf("- **Lower Z-boundaries (futility):** %s",
                              paste(lz, collapse = ", ")))
    }
  }
  if (!is.null(t)) {
    if (!is.null(t$information_fraction))
      rows <- c(rows, sprintf("- **Information fractions:** %s",
                              paste(sprintf("%.3f", t$information_fraction),
                                    collapse = ", ")))
    if (!is.null(t$events_per_analysis))
      rows <- c(rows, sprintf("- **Events per analysis:** %s",
                              paste(round(t$events_per_analysis), collapse = ", ")))
    if (!is.null(t$n_per_analysis))
      rows <- c(rows, sprintf("- **N per analysis:** %s",
                              paste(round(t$n_per_analysis), collapse = ", ")))
    if (!is.null(t$analysis_times))
      rows <- c(rows, sprintf("- **Calendar analysis times (months):** %s",
                              paste(sprintf("%.2f", t$analysis_times),
                                    collapse = ", ")))
    if (!is.null(t$accrual_duration))
      rows <- c(rows, sprintf("- **Accrual / follow-up:** %.1f / %.1f months (total %.1f)",
                              t$accrual_duration,
                              t$followup_duration %||% NA_real_,
                              t$study_duration   %||% t$total_duration %||% NA_real_))
  }
  if (length(rows) == 0) "_(none)_" else paste(rows, collapse = "\n")
}

# ---- docx renderer (officer) -------------------------------------------------
#
# Renders the same content as the markdown report but as native Word
# paragraphs / headings / tables — not by piping markdown through Pandoc.
# Word doesn't have a markdown table primitive, so we build proper Word
# tables for the reasoning chain and the analysis plan.
#
# Falls back to writing the markdown text alongside if officer is absent.

.render_docx <- function(result, path) {
  if (!requireNamespace("officer", quietly = TRUE)) {
    designr_stop("format",
                 "format='docx' requires the 'officer' R package (install.packages('officer'))")
  }
  if (is.null(path)) {
    path <- tempfile(pattern = "ClinicalTrialDesign_report_", fileext = ".docx")
  }

  fam <- .report_family(result$method)
  inp <- result$inputs

  doc <- officer::read_docx()

  # Title
  doc <- officer::body_add_par(doc, .report_title(fam, inp), style = "heading 1")

  # Sponsor-confidential warning, if applicable
  if (reasoning_has_confidential(result$reasoning_chain)) {
    doc <- officer::body_add_par(doc,
      "⚠ Sponsor-confidential content. The reasoning chain contains entries tagged source_type=sponsor_confidential. Review and redact before sharing externally.",
      style = "Normal")
    doc <- officer::body_add_par(doc, "", style = "Normal")
  }

  # Sections
  doc <- officer::body_add_par(doc, "Design overview", style = "heading 2")
  for (line in .report_overview_lines(fam, inp)) {
    doc <- officer::body_add_par(doc, line, style = "Normal")
  }

  doc <- officer::body_add_par(doc, "Key inputs", style = "heading 2")
  for (line in .report_inputs_lines(fam, inp)) {
    doc <- officer::body_add_par(doc, line, style = "Normal")
  }

  doc <- officer::body_add_par(doc, "Headline output", style = "heading 2")
  for (line in .report_output_lines(result)) {
    doc <- officer::body_add_par(doc, line, style = "Normal")
  }

  if (!is.null(result$boundaries) || !is.null(result$timing)) {
    doc <- officer::body_add_par(doc, "Analysis plan", style = "heading 2")
    for (line in .report_analysis_plan_lines(result)) {
      doc <- officer::body_add_par(doc, line, style = "Normal")
    }
  }

  rc <- result$reasoning_chain
  if (!is.null(rc) && length(rc) > 0L) {
    doc <- officer::body_add_par(doc, "Reasoning chain", style = "heading 2")
    rc_df <- data.frame(
      Decision      = vapply(rc, function(e) as.character(e$decision      %||% ""), character(1)),
      Value         = vapply(rc, function(e) {
                         v <- e$value
                         if (is.null(v)) "—"
                         else if (is.numeric(v)) sprintf("%g", v)
                         else as.character(v)
                       }, character(1)),
      Justification = vapply(rc, function(e) as.character(e$justification %||% ""), character(1)),
      Source        = vapply(rc, function(e) {
                         s <- as.character(e$source_type %||% "")
                         if (identical(s, "sponsor_confidential"))
                           paste0(s, " ⚠") else s
                       }, character(1)),
      Reference     = vapply(rc, function(e) as.character(e$source_ref %||% "—"), character(1)),
      stringsAsFactors = FALSE
    )
    doc <- officer::body_add_table(doc, value = rc_df, style = NULL,
                                   first_row = TRUE, header = TRUE)
  }

  doc <- officer::body_add_par(doc, "Method & version", style = "heading 2")
  doc <- officer::body_add_par(doc, sprintf("Method: %s", result$method),
                               style = "Normal")
  doc <- officer::body_add_par(doc, sprintf("Backend version: %s",
                               result$package_version %||% "n/a"),
                               style = "Normal")
  doc <- officer::body_add_par(doc, sprintf("ClinicalTrialDesign version: %s",
                               tryCatch(as.character(utils::packageVersion("ClinicalTrialDesign")),
                                        error = function(e) "loaded")),
                               style = "Normal")

  print(doc, target = path)
  invisible(path)
}

# ---- pdf renderer (rmarkdown) ------------------------------------------------
#
# rmarkdown::render the markdown body via pdf_document. Requires Pandoc +
# a TeX engine (the README documents these). If Pandoc is absent we error
# with a clear message that points the user to format='markdown' instead.

.render_pdf <- function(result, path) {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    designr_stop("format",
                 "format='pdf' requires the 'rmarkdown' R package")
  }
  if (!nzchar(Sys.which("pandoc")) && !rmarkdown::pandoc_available()) {
    designr_stop("format",
                 "format='pdf' requires Pandoc on the system PATH; install Pandoc or call design_report(format='markdown') and convert externally")
  }
  if (is.null(path)) {
    path <- tempfile(pattern = "ClinicalTrialDesign_report_", fileext = ".pdf")
  }
  md_body <- design_report(result, format = "markdown")
  md_path <- tempfile(fileext = ".md")
  writeLines(md_body, md_path)

  rmarkdown::render(input        = md_path,
                    output_format = "pdf_document",
                    output_file  = basename(path),
                    output_dir   = dirname(path),
                    quiet        = TRUE)
  invisible(path)
}

# ---- helpers shared between markdown and docx --------------------------------

.report_overview_lines <- function(family, inp) {
  comp <- inp$comparison %||% "superiority"
  rows <- c(
    sprintf("Family: %s", family),
    sprintf("Comparison: %s", comp),
    sprintf("Sided: %s", inp$sided %||% "—"),
    sprintf("Allocation ratio (T:C): %s", inp$allocation_ratio %||% 1)
  )
  if (!is.null(inp$k))      rows <- c(rows, sprintf("Analyses (k): %d", inp$k))
  if (!is.null(inp$sfu))    rows <- c(rows, sprintf("Upper spending: %s", inp$sfu))
  if (!is.null(inp$sfl))    rows <- c(rows, sprintf("Lower spending: %s", inp$sfl))
  rows
}

.report_inputs_lines <- function(family, inp) {
  show <- function(label, val, fmt = "%s") {
    if (is.null(val) || (is.atomic(val) && all(is.na(val)))) return(NULL)
    sprintf("%s: %s", label, sprintf(fmt, val))
  }
  rows <- c(
    show("Alpha", inp$alpha,  "%.4f"),
    show("Power", inp$power,  "%.3f"),
    show("Control event rate",   inp$p_control,    "%.3f"),
    show("Treatment event rate", inp$p_treatment,  "%.3f"),
    show("Mean difference",      inp$mean_diff,    "%.3f"),
    show("Common SD",            inp$sd,           "%.3f"),
    show("Control median (months)", inp$control_median, "%.2f"),
    show("Hazard ratio (target)",   inp$hazard_ratio,    "%.3f"),
    show("Accrual duration (months)", inp$accrual_duration, "%.1f"),
    show("Follow-up after last enroll (months)", inp$followup_duration, "%.1f"),
    show("Dropout rate (per month)", inp$dropout_rate, "%.4f"),
    show("Non-inferiority margin", inp$ni_margin, "%.4f"),
    show("Equivalence margin",      inp$equiv_margin, "%.4f")
  )
  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0) "(no inputs)" else rows
}

.report_output_lines <- function(result) {
  rows <- c(sprintf("Total sample size: %s", result$sample_size_total))
  if (!is.null(result$sample_size_per_arm)) {
    pa <- result$sample_size_per_arm
    nm <- names(pa)
    if (is.null(nm) || all(nm == "")) nm <- paste0("arm", seq_along(pa))
    parts <- vapply(seq_along(pa),
                    function(i) sprintf("%s = %s", nm[i], pa[i]),
                    character(1))
    rows <- c(rows, sprintf("Per-arm: %s", paste(parts, collapse = ", ")))
  }
  if (!is.null(result$events_total)) {
    rows <- c(rows, sprintf("Total events: %s", result$events_total))
  }
  rows
}

.report_analysis_plan_lines <- function(result) {
  rows <- character(0)
  b <- result$boundaries
  t <- result$timing
  if (!is.null(b) && !is.null(b$upper_z)) {
    z <- vapply(b$upper_z, function(x) sprintf("%.3f", x), character(1))
    rows <- c(rows, sprintf("Upper Z-boundaries: %s", paste(z, collapse = ", ")))
    if (!is.null(b$upper_p)) {
      p <- vapply(b$upper_p, function(x) sprintf("%.4f", x), character(1))
      rows <- c(rows, sprintf("Nominal p-boundaries: %s", paste(p, collapse = ", ")))
    }
  }
  if (!is.null(t)) {
    if (!is.null(t$information_fraction))
      rows <- c(rows, sprintf("Information fractions: %s",
                              paste(sprintf("%.3f", t$information_fraction),
                                    collapse = ", ")))
    if (!is.null(t$events_per_analysis))
      rows <- c(rows, sprintf("Events per analysis: %s",
                              paste(round(t$events_per_analysis), collapse = ", ")))
  }
  rows
}
