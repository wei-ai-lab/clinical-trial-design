#' Multi-population (subgroup) design
#'
#' Compute a confirmatory design that tests the same endpoint in two or more
#' populations (typically a biomarker-positive subgroup plus the broader
#' ITT-like population). Multiplicity is controlled via fixed-sequence
#' (hierarchical), alpha-split, or Bonferroni.
#'
#' Two population-relation modes:
#' \itemize{
#'   \item \strong{nested} (default) — populations are subsets of a single
#'     enrolled cohort (e.g., TPS≥50 ⊂ TPS≥20 ⊂ ITT). All patients enroll into
#'     the broadest population; subgroup analyses use the prevalence-weighted
#'     subset of those patients. Total enrolled N is driven by the population
#'     whose required-N-given-prevalence is largest.
#'   \item \strong{disjoint} — populations are non-overlapping strata enrolled
#'     separately (rare in practice; supported for completeness). Total N is
#'     the sum of per-population N.
#' }
#'
#' For each population, the assumed effect (HR for survival, p_treatment for
#' binary, delta for continuous) replaces the corresponding parameter in
#' \code{endpoint_args}. The endpoint family and its non-effect parameters
#' (control_median, sd, accrual_duration, etc.) are shared across populations.
#'
#' @param endpoint_type One of \code{"binary"}, \code{"continuous"},
#'   \code{"survival"}.
#' @param endpoint_args A named list of arguments passed to the matching
#'   \code{design_<type>} wrapper. The effect parameter (\code{hazard_ratio}
#'   for survival, \code{p_treatment} for binary, \code{delta} for continuous)
#'   is overridden per population by \code{populations[[name]]$effect}.
#' @param populations A named list of populations. Each entry has:
#'   \itemize{
#'     \item \code{prevalence} — fraction of the broadest population (used for
#'       nested mode).
#'     \item \code{effect} — list of effect parameters appropriate to
#'       \code{endpoint_type}, e.g. \code{list(hazard_ratio = 0.65)} for
#'       survival, \code{list(p_treatment = 0.10)} for binary,
#'       \code{list(delta = 0.4)} for continuous.
#'   }
#' @param relation One of \code{"nested"} or \code{"disjoint"}.
#' @param strategy One of \code{"fixed-sequence"}, \code{"alpha-split"},
#'   \code{"bonferroni"}.
#' @param alpha Family-wise type I error (default 0.025).
#' @param sided Sidedness (default 1).
#' @param power Per-population power (default 0.80).
#' @param allocation_ratio Treatment-to-control allocation ratio (default 1).
#' @param alpha_weights For \code{strategy = "alpha-split"}: named numeric
#'   vector summing to 1.
#' @param ordering For \code{strategy = "fixed-sequence"}: character vector of
#'   population names in test order.
#'
#' @return Unified result list with:
#'   \itemize{
#'     \item \code{sample_size_total} — for nested: max of per-population
#'       enrolled-N; for disjoint: sum of per-population N
#'     \item \code{populations} — per-population design results, including
#'       \code{N_in_population} (the events-driving subset) and
#'       \code{N_implied_enrolled} (the broader N required to capture that
#'       subset given the prevalence)
#'     \item \code{multiplicity} — strategy + per-population alphas
#'     \item \code{driver} — name of the population that drove total N
#'     \item \code{relation} — "nested" or "disjoint"
#'     \item \code{inputs}, \code{method}, \code{package_version}
#'   }
#'
#' @examples
#' \dontrun{
#' # KEYNOTE-042 style: nested OS with three PD-L1 strata
#' design_multi_population(
#'   endpoint_type = "survival",
#'   endpoint_args = list(model = "ph", design_class = "fixed",
#'                        control_median = 12.2,
#'                        accrual_duration = 25, followup_duration = 12,
#'                        dropout_rate = 0.0042),
#'   populations = list(
#'     "TPS_50" = list(prevalence = 0.47, effect = list(hazard_ratio = 0.65)),
#'     "TPS_20" = list(prevalence = 0.63, effect = list(hazard_ratio = 0.70)),
#'     "TPS_1"  = list(prevalence = 1.00, effect = list(hazard_ratio = 0.78))
#'   ),
#'   relation = "nested",
#'   strategy = "fixed-sequence",
#'   alpha = 0.025, power = 0.85, allocation_ratio = 1
#' )
#' }
#'
#' @export
design_multi_population <- function(endpoint_type,
                                    endpoint_args,
                                    populations,
                                    relation         = "nested",
                                    strategy         = "fixed-sequence",
                                    alpha            = 0.025,
                                    sided            = 1,
                                    power            = 0.80,
                                    allocation_ratio = 1,
                                    alpha_weights    = NULL,
                                    ordering         = NULL,
                                    reasoning_chain  = NULL) {

  reasoning_chain <- check_reasoning_chain(reasoning_chain)

  # --- input validation -----------------------------------------------------
  if (!endpoint_type %in% c("binary", "continuous", "survival")) {
    stop(sprintf(
      "designr_input_error: endpoint_type: must be binary, continuous, or survival (got '%s')",
      endpoint_type))
  }
  if (!is.list(endpoint_args)) {
    stop("designr_input_error: endpoint_args: must be a named list")
  }
  if (!is.list(populations) || length(populations) < 2L) {
    stop("designr_input_error: populations: must be a named list of length >= 2")
  }
  pop_names <- names(populations)
  if (is.null(pop_names) || any(!nzchar(pop_names)) || anyDuplicated(pop_names)) {
    stop("designr_input_error: populations: must have unique non-empty names")
  }
  for (nm in pop_names) {
    p <- populations[[nm]]
    if (!is.list(p) || is.null(p$effect)) {
      stop(sprintf(
        "designr_input_error: populations: '%s' must be a list with an 'effect' field",
        nm))
    }
    if (relation == "nested") {
      if (is.null(p$prevalence) || !is.numeric(p$prevalence) ||
          p$prevalence <= 0 || p$prevalence > 1) {
        stop(sprintf(
          "designr_input_error: populations: '%s' nested mode requires prevalence in (0, 1]",
          nm))
      }
    }
  }
  if (!relation %in% c("nested", "disjoint")) {
    stop("designr_input_error: relation: must be 'nested' or 'disjoint'")
  }
  if (!strategy %in% c("fixed-sequence", "alpha-split", "bonferroni")) {
    stop("designr_input_error: strategy: must be one of 'fixed-sequence', 'alpha-split', 'bonferroni'")
  }
  if (!is.numeric(alpha) || alpha <= 0 || alpha >= 1) {
    stop("designr_input_error: alpha: must be in (0, 1)")
  }

  k <- length(populations)

  # --- per-population effective alpha --------------------------------------
  per_alpha <- switch(strategy,
    "fixed-sequence" = setNames(rep(alpha, k), pop_names),
    "bonferroni"     = setNames(rep(alpha / k, k), pop_names),
    "alpha-split"    = {
      if (is.null(alpha_weights)) {
        alpha_weights <- setNames(rep(1 / k, k), pop_names)
      }
      if (!setequal(names(alpha_weights), pop_names)) {
        stop("designr_input_error: alpha_weights: names must match populations exactly")
      }
      if (abs(sum(alpha_weights) - 1) > 1e-6) {
        stop("designr_input_error: alpha_weights: must sum to 1")
      }
      setNames(alpha * alpha_weights[pop_names], pop_names)
    }
  )

  if (strategy == "fixed-sequence") {
    if (is.null(ordering)) ordering <- pop_names
    if (!setequal(ordering, pop_names)) {
      stop("designr_input_error: ordering: must contain every population name exactly once")
    }
  }

  # --- design each population ---------------------------------------------
  fn <- switch(endpoint_type,
    binary     = design_binary,
    continuous = design_continuous,
    survival   = design_survival
  )

  effect_param <- switch(endpoint_type,
    binary     = "p_treatment",
    continuous = "delta",
    survival   = "hazard_ratio"
  )

  per_pop <- list()
  for (nm in pop_names) {
    p <- populations[[nm]]
    args <- endpoint_args

    # Override effect parameter(s) per population
    for (k_eff in names(p$effect)) {
      args[[k_eff]] <- p$effect[[k_eff]]
    }

    # Inject the effective alpha + family-wide defaults
    args$alpha            <- per_alpha[[nm]]
    args$sided            <- if (is.null(args$sided)) sided else args$sided
    args$power            <- if (is.null(args$power)) power else args$power
    args$allocation_ratio <- if (is.null(args$allocation_ratio))
      allocation_ratio else args$allocation_ratio
    args$comparison       <- if (is.null(args$comparison))
      "superiority" else args$comparison

    res <- tryCatch(
      do.call(fn, args),
      error = function(err) {
        msg <- conditionMessage(err)
        if (startsWith(msg, "designr_input_error:")) {
          stop(sprintf(
            "designr_input_error: populations: '%s': %s", nm,
            sub("^designr_input_error:\\s*", "", msg)))
        }
        stop(err)
      }
    )

    n_in_pop <- res$sample_size_total
    n_implied <- if (relation == "nested") {
      ceiling(n_in_pop / p$prevalence)
    } else {
      n_in_pop
    }
    res$N_in_population    <- n_in_pop
    res$N_implied_enrolled <- as.integer(n_implied)
    res$prevalence         <- p$prevalence
    per_pop[[nm]] <- res
  }

  # --- aggregate total N --------------------------------------------------
  ns_implied <- vapply(per_pop, `[[`, numeric(1), "N_implied_enrolled")
  total_n <- if (relation == "nested") max(ns_implied) else sum(ns_implied)
  driver <- if (relation == "nested") names(ns_implied)[which.max(ns_implied)] else NA_character_

  per_arm <- .per_arm(total_n, allocation_ratio)

  multiplicity <- list(
    strategy        = strategy,
    per_population_alpha = as.list(per_alpha),
    family_alpha    = alpha,
    rationale       = switch(strategy,
      "fixed-sequence" = "Each population tested at full family alpha; gating preserves family-wise alpha by closed testing.",
      "alpha-split"    = "Family alpha partitioned by user-supplied weights; per-population alpha = alpha * w_i.",
      "bonferroni"     = "Equal-weight alpha-split (alpha / k per population).")
  )

  inputs <- list(
    endpoint_type    = endpoint_type,
    endpoint_args    = endpoint_args,
    populations      = populations,
    relation         = relation,
    strategy         = strategy,
    alpha            = alpha,
    sided            = sided,
    power            = power,
    allocation_ratio = allocation_ratio
  )
  if (strategy == "fixed-sequence") inputs$ordering <- ordering
  if (strategy == "alpha-split")    inputs$alpha_weights <- alpha_weights

  .designr_result(
    sample_size_total   = total_n,
    sample_size_per_arm = per_arm,
    events_total        = NULL,
    boundaries          = NULL,
    timing              = NULL,
    operational         = NULL,
    reasoning_chain     = reasoning_chain,
    inputs              = inputs,
    method              = sprintf("design_multi_population[%s,%s]", relation, strategy),
    package_version     = .pkg_version("ClinicalTrialDesign"),
    raw                 = list(
      populations  = per_pop,
      driver       = driver,
      relation     = relation,
      multiplicity = multiplicity
    )
  )
}
