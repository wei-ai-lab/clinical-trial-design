#' Normalize gsDesign / gsDesign2 output to a JSON-friendly list
#'
#' Every `design_*` function returns the same top-level shape so the MCP
#' bridge (and downstream callers) can rely on a flat schema regardless of
#' which backend did the work.
#'
#' Canonical shape:
#' \itemize{
#'   \item `sample_size_total` — integer or numeric.
#'   \item `sample_size_per_arm` — numeric vector (arm order matches input).
#'   \item `events_total` — numeric, NULL for non-survival designs.
#'   \item `boundaries` — list with per-analysis z-values / p-values, NULL for fixed-sample.
#'   \item `timing` — list with information fractions / event counts per analysis, NULL for fixed-sample.
#'   \item `inputs` — echoed parsed inputs.
#'   \item `method` — short label ("gsDesign::nBinomial", "gsDesign2::gs_design_combo", …).
#'   \item `package_version` — version of the backing package used.
#'   \item `raw` — anything that did not fit above, captured verbatim for debugging.
#' }
#'
#' @name utils_format
#' @keywords internal
NULL

.designr_result <- function(sample_size_total,
                            sample_size_per_arm,
                            events_total = NULL,
                            boundaries   = NULL,
                            timing       = NULL,
                            operational  = NULL,
                            reasoning_chain = NULL,
                            inputs,
                            method,
                            package_version,
                            raw = NULL) {
  # Enforce the invariant sum(per_arm) == total by ceiling the per-arm
  # vector first, then summing. Independent ceils can drift by 1.
  per_arm <- ceiling(sample_size_per_arm)
  total   <- as.integer(sum(per_arm))
  per_arm_int <- as.integer(per_arm)
  names(per_arm_int) <- names(per_arm)
  list(
    sample_size_total   = total,
    sample_size_per_arm = per_arm_int,
    events_total        = if (is.null(events_total)) NULL else as.integer(ceiling(events_total)),
    boundaries          = boundaries,
    timing              = timing,
    operational         = operational,
    reasoning_chain     = reasoning_chain,
    inputs              = inputs,
    method              = method,
    package_version     = as.character(package_version),
    raw                 = raw
  )
}

.per_arm <- function(n_total, ratio) {
  n_control <- n_total / (1 + ratio)
  n_treat   <- n_total - n_control
  c(control = n_control, treatment = n_treat)
}

.pkg_version <- function(pkg) {
  tryCatch(as.character(utils::packageVersion(pkg)), error = function(e) NA_character_)
}
