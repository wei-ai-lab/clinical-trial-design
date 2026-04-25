#' Validate a design tool against a benchmark corpus case
#'
#' Loads the YAML file for benchmark case `id` in `family`, re-runs the
#' matching design tool with the case's inputs, and diffs the tool's headline
#' quantities (`sample_size_total`, `events_total`) against `expected.*`
#' within the case's declared tolerance.
#'
#' The benchmark corpus is expected at `<pkg_root>/../../benchmarks/` or at
#' `/home/weiai/designr/benchmarks/` (the repo layout used during development).
#' Override via the `DESIGNR_BENCHMARK_ROOT` environment variable.
#'
#' @param family Family directory under `benchmarks/`
#'   (e.g. `"fixed-superiority"`, `"group-sequential"`).
#' @param id Case ID — the YAML filename without `.yaml`
#'   (e.g. `"1997_CAPTURE_abciximab"`).
#' @param tool Optional — override the design tool dispatched. If NULL
#'   (default), inferred from the case's `design.family` / `endpoint_type`
#'   fields.
#' @return A list with `case_id`, `tool`, `computed`, `expected`, `tolerance`,
#'   and `within_tolerance` (logical).
#' @export
validate_against_benchmark <- function(family, id, tool = NULL) {
  if (!is.character(family) || length(family) != 1L) {
    designr_stop("family", "must be a single string")
  }
  if (!is.character(id) || length(id) != 1L) {
    designr_stop("id", "must be a single string")
  }
  yaml_path <- file.path(.bench_root(), family, "cases", paste0(id, ".yaml"))
  if (!file.exists(yaml_path)) {
    designr_stop("id", sprintf("no benchmark case at %s", yaml_path))
  }
  case <- yaml::read_yaml(yaml_path)

  if (is.null(tool)) tool <- .infer_tool(case, family)
  fn <- .tool_registry[[tool]]
  if (is.null(fn)) designr_stop("tool", sprintf("unknown design tool '%s'", tool))

  args <- .case_to_args(case, tool)
  computed <- do.call(fn, args)
  expected <- case$expected %||% list()
  tolerance <- expected$tolerance %||% case$tolerance %||% list()

  diffs <- list()
  within <- TRUE
  if (!is.null(expected$sample_size_total) && !is.null(computed$sample_size_total)) {
    pct <- tolerance$sample_size_pct %||% 10
    delta <- abs(computed$sample_size_total - expected$sample_size_total) /
             expected$sample_size_total * 100
    diffs$sample_size_total <- list(
      computed = computed$sample_size_total,
      expected = expected$sample_size_total,
      pct_diff = delta, tolerance_pct = pct,
      within   = delta <= pct
    )
    within <- within && delta <= pct
  }
  if (!is.null(expected$events_total) && !is.null(computed$events_total)) {
    pct <- tolerance$events_pct %||% tolerance$sample_size_pct %||% 10
    delta <- abs(computed$events_total - expected$events_total) /
             expected$events_total * 100
    diffs$events_total <- list(
      computed = computed$events_total,
      expected = expected$events_total,
      pct_diff = delta, tolerance_pct = pct,
      within   = delta <= pct
    )
    within <- within && delta <= pct
  }

  list(
    case_id          = id,
    family           = family,
    tool             = tool,
    computed         = computed,
    expected         = expected,
    tolerance        = tolerance,
    diffs            = diffs,
    within_tolerance = within
  )
}

`%||%` <- function(a, b) if (is.null(a)) b else a

.bench_root <- function() {
  env <- Sys.getenv("DESIGNR_BENCHMARK_ROOT", unset = NA_character_)
  if (!is.na(env) && dir.exists(env)) return(normalizePath(env))
  pkg_root <- tryCatch(
    system.file(package = "ClinicalTrialDesign"), error = function(e) "")
  candidates <- c(
    file.path(pkg_root, "..", "..", "..", "benchmarks"),
    "/home/weiai/designr/benchmarks"
  )
  for (c in candidates) {
    if (isTRUE(dir.exists(c))) return(normalizePath(c))
  }
  designr_stop("benchmark_root",
               "could not locate benchmarks/; set DESIGNR_BENCHMARK_ROOT")
}

.infer_tool <- function(case, family) {
  fam <- case$family %||% case$design$family %||% family
  ep  <- case$design$endpoint$type %||% case$design$endpoint_type %||% case$endpoint_type
  if (is.null(fam) || is.null(ep)) {
    designr_stop("tool", "cannot infer tool: missing family / endpoint type")
  }
  fam_class <- if (startsWith(fam, "fixed")) "fixed"
               else if (startsWith(fam, "group-sequential-nph")) "gs-nph"
               else if (startsWith(fam, "group-sequential")) "gs-ph"
               else if (fam %in% c("tte-ph", "tte-nph")) "fixed"
               else fam
  key <- paste(fam_class, ep, sep = ":")
  switch(key,
    "fixed:binary"         = "design_fixed_binary",
    "fixed:continuous"     = "design_fixed_continuous",
    "fixed:survival-ph"    = "design_fixed_survival_ph",
    "fixed:tte-ph"         = "design_fixed_survival_ph",
    "fixed:survival-nph"   = "design_fixed_survival_maxcombo",
    "fixed:tte-nph"        = "design_fixed_survival_maxcombo",
    "fixed:survival-rmst"  = "design_fixed_survival_rmst",
    "fixed:survival-milestone" = "design_fixed_survival_milestone",
    "gs-ph:binary"     = "design_gs_binary",
    "gs-ph:continuous" = "design_gs_continuous",
    "gs-ph:survival-ph" = "design_gs_survival_ph",
    "gs-ph:tte-ph"      = "design_gs_survival_ph",
    "gs-nph:survival-nph" = "design_gs_survival_nph_combo",
    "gs-nph:tte-nph"      = "design_gs_survival_nph_combo",
    designr_stop("tool", sprintf("no wrapper mapped for '%s'", key))
  )
}

.case_to_args <- function(case, tool) {
  d <- case$design %||% list()
  e <- d$effect %||% case$effect %||% list()
  sided <- d$sidedness %||% d$sided %||% 2
  alpha <- d$alpha %||% 0.025
  power <- d$power %||% 0.9
  comparison <- d$comparison %||% "superiority"
  ratio <- d$allocation_ratio %||% 1
  switch(tool,
    "design_fixed_binary" = list(
      p_control   = e$control_rate %||% e$p_control,
      p_treatment = e$treatment_rate %||% e$p_treatment,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = ratio, comparison = comparison,
      ni_margin = d$ni_margin, equiv_margin = d$equiv_margin
    ),
    "design_fixed_continuous" = list(
      mean_diff = e$mean_diff, sd = e$sd,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = ratio, comparison = comparison,
      ni_margin = d$ni_margin, equiv_margin = d$equiv_margin
    ),
    "design_fixed_survival_ph" = list(
      control_median = e$control_median, hazard_ratio = e$hazard_ratio,
      accrual_rate = e$accrual_rate %||% d$accrual$rate,
      accrual_duration = e$accrual_duration %||% d$accrual$duration_months,
      followup_duration = e$followup_duration %||% d$followup_duration_months,
      dropout_rate = e$dropout_rate %||% 0.001,
      alpha = alpha, power = power,
      sided = if (sided == 2) 1 else sided,
      allocation_ratio = ratio
    ),
    as.list(e)
  )
}
