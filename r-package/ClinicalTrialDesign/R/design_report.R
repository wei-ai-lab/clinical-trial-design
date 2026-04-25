#' Markdown summary of a ClinicalTrialDesign result
#'
#' Produces a clinician-readable report from the JSON-shaped result returned
#' by any `design_*` tool. Useful for review meetings and as a saveable
#' artifact: the markdown can be pasted into a SAP-style document or
#' rendered to HTML / PDF / Word downstream.
#'
#' For v0.0.2 only `format = "markdown"` is supported. Word / PDF output is
#' deferred (a heavy Python-template path is the long-term option, modeled
#' on `RConsortium/pharma-skills`'s reporter).
#'
#' @param result A `ClinicalTrialDesign` result list (the `$result` payload
#'   returned by the MCP bridge).
#' @param format Output format. Currently only `"markdown"`.
#'
#' @return A length-1 character vector holding the formatted report.
#' @export
design_report <- function(result, format = c("markdown", "text")) {
  if (!is.list(result) || is.null(result$method) || is.null(result$inputs)) {
    designr_stop("result", "must be a ClinicalTrialDesign result list with $method and $inputs")
  }
  format <- match.arg(format)
  fam <- .report_family(result$method)
  inp <- result$inputs

  lines <- character(0)
  lines <- c(lines, sprintf("# %s", .report_title(fam, inp)),
             "",
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
  lines <- c(lines,
             "## Method & version", "",
             sprintf("- **Method:** `%s`", result$method),
             sprintf("- **Backend version:** `%s`", result$package_version %||% "n/a"),
             sprintf("- **ClinicalTrialDesign version:** `%s`",
                     tryCatch(as.character(utils::packageVersion("ClinicalTrialDesign")),
                              error = function(e) "loaded")))
  paste(lines, collapse = "\n")
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
                              t$accrual_duration, t$followup_duration, t$total_duration))
  }
  if (length(rows) == 0) "_(none)_" else paste(rows, collapse = "\n")
}
