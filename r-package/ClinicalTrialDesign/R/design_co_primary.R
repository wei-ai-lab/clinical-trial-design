#' Co-primary multi-endpoint design
#'
#' Compute a confirmatory design with two or more co-primary endpoints under
#' one of three multiplicity-control strategies:
#' \itemize{
#'   \item \strong{fixed-sequence (hierarchical)} — each endpoint tested at the
#'     full family-wise alpha conditional on rejection of all earlier-ordered
#'     endpoints. Family-wise type I error is preserved by the closed-testing
#'     principle (the secondary endpoint can only be tested in the path where
#'     the primary has rejected). No alpha-split — full alpha per test.
#'   \item \strong{alpha-split} — alpha is partitioned across endpoints by
#'     user-supplied weights. Each endpoint is tested at \code{alpha * w_i}
#'     independently. Family-wise alpha is controlled by Bonferroni-type
#'     argument. Conservative if endpoints are correlated.
#'   \item \strong{bonferroni} — equivalent to \code{alpha-split} with equal
#'     weights (\code{alpha / k}). Provided as a separate strategy name for
#'     convenience and clarity.
#' }
#'
#' Total sample size is the maximum across the per-endpoint N requirements.
#' Per-endpoint events / boundaries are reported under \code{endpoints} in
#' the result.
#'
#' For graphical multiplicity (Maurer-Bretz with alpha recycling), use
#' \code{\link{design_graphical_multiplicity}} instead.
#'
#' @param endpoints A named list, one entry per co-primary endpoint. Each entry
#'   is itself a list with \code{type ∈ \{"binary", "continuous", "survival"\}}
#'   and the parameters that the corresponding \code{design_<type>} function
#'   would accept. For survival, include \code{model} and \code{design_class}
#'   if not the default (\code{"ph"} / \code{"fixed"}).
#' @param strategy One of \code{"fixed-sequence"}, \code{"alpha-split"},
#'   \code{"bonferroni"}.
#' @param alpha Family-wise type I error (default 0.025, one-sided).
#' @param sided Sidedness (default 1).
#' @param power Per-endpoint power (default 0.80). Family-wise power
#'   (joint rejection) under fixed-sequence is approximately the product of
#'   per-endpoint powers under independence; depends on correlation in
#'   practice.
#' @param allocation_ratio Treatment-to-control allocation ratio, shared
#'   across endpoints (default 1).
#' @param alpha_weights For \code{strategy = "alpha-split"}: named numeric
#'   vector summing to 1 with weights for each endpoint, in the same names
#'   as \code{endpoints}. Default: equal weights.
#' @param ordering For \code{strategy = "fixed-sequence"}: character vector
#'   naming endpoints in test order. Default: \code{names(endpoints)}.
#'
#' @return A unified result list:
#'   \itemize{
#'     \item \code{sample_size_total} — max across endpoints (operational driver)
#'     \item \code{sample_size_per_arm} — per-arm split at the total N
#'     \item \code{endpoints} — list of per-endpoint design results, each with
#'       its own \code{sample_size_total}, \code{events_total}, \code{boundaries}
#'     \item \code{multiplicity} — strategy + per-endpoint alphas used
#'     \item \code{driver} — name of the endpoint that drove the total N
#'     \item \code{inputs}, \code{method}, \code{package_version}
#'   }
#'
#' @examples
#' \dontrun{
#' # KEYNOTE-189 style: co-primary PFS + OS, hierarchical (PFS first)
#' design_co_primary(
#'   endpoints = list(
#'     PFS = list(type = "survival", model = "ph", design_class = "fixed",
#'                control_median = 4.7, hazard_ratio = 0.50,
#'                accrual_duration = 20, followup_duration = 12),
#'     OS  = list(type = "survival", model = "ph", design_class = "fixed",
#'                control_median = 17.0, hazard_ratio = 0.70,
#'                accrual_duration = 20, followup_duration = 24)
#'   ),
#'   strategy = "fixed-sequence",
#'   alpha = 0.025, power = 0.80, allocation_ratio = 2
#' )
#' }
#'
#' @export
design_co_primary <- function(endpoints,
                              strategy         = "fixed-sequence",
                              alpha            = 0.025,
                              sided            = 1,
                              power            = 0.80,
                              allocation_ratio = 1,
                              alpha_weights    = NULL,
                              ordering         = NULL) {

  # --- input validation -----------------------------------------------------
  if (!is.list(endpoints) || length(endpoints) < 2L) {
    stop("designr_input_error: endpoints: must be a named list of length >= 2")
  }
  ep_names <- names(endpoints)
  if (is.null(ep_names) || any(!nzchar(ep_names)) || anyDuplicated(ep_names)) {
    stop("designr_input_error: endpoints: must have unique non-empty names")
  }
  for (nm in ep_names) {
    e <- endpoints[[nm]]
    if (!is.list(e) || is.null(e$type)) {
      stop(sprintf(
        "designr_input_error: endpoints: '%s' must be a list with a 'type' field",
        nm))
    }
    if (!e$type %in% c("binary", "continuous", "survival")) {
      stop(sprintf(
        "designr_input_error: endpoints: '%s' has unsupported type '%s' (use binary, continuous, survival)",
        nm, e$type))
    }
  }

  if (!strategy %in% c("fixed-sequence", "alpha-split", "bonferroni")) {
    stop("designr_input_error: strategy: must be one of 'fixed-sequence', 'alpha-split', 'bonferroni'")
  }

  if (!is.numeric(alpha) || alpha <= 0 || alpha >= 1) {
    stop("designr_input_error: alpha: must be in (0, 1)")
  }

  k <- length(endpoints)

  # --- compute per-endpoint effective alpha --------------------------------
  per_alpha <- switch(strategy,
    "fixed-sequence" = setNames(rep(alpha, k), ep_names),
    "bonferroni"     = setNames(rep(alpha / k, k), ep_names),
    "alpha-split"    = {
      if (is.null(alpha_weights)) {
        alpha_weights <- setNames(rep(1 / k, k), ep_names)
      }
      if (!is.numeric(alpha_weights) || is.null(names(alpha_weights))) {
        stop("designr_input_error: alpha_weights: must be a named numeric vector")
      }
      if (!setequal(names(alpha_weights), ep_names)) {
        stop("designr_input_error: alpha_weights: names must match endpoints exactly")
      }
      if (abs(sum(alpha_weights) - 1) > 1e-6) {
        stop("designr_input_error: alpha_weights: must sum to 1")
      }
      setNames(alpha * alpha_weights[ep_names], ep_names)
    }
  )

  # --- normalize ordering for fixed-sequence -------------------------------
  if (strategy == "fixed-sequence") {
    if (is.null(ordering)) ordering <- ep_names
    if (!setequal(ordering, ep_names)) {
      stop("designr_input_error: ordering: must contain every endpoint name exactly once")
    }
  }

  # --- design each endpoint at its effective alpha --------------------------
  per_ep <- list()
  for (nm in ep_names) {
    e <- endpoints[[nm]]
    args <- e[setdiff(names(e), "type")]

    # Inject family-wide defaults (caller can still override per-endpoint)
    args$alpha            <- per_alpha[[nm]]
    args$sided            <- if (is.null(args$sided)) sided else args$sided
    args$power            <- if (is.null(args$power)) power else args$power
    args$allocation_ratio <- if (is.null(args$allocation_ratio))
      allocation_ratio else args$allocation_ratio
    args$comparison       <- if (is.null(args$comparison))
      "superiority" else args$comparison

    fn <- switch(e$type,
      binary     = design_binary,
      continuous = design_continuous,
      survival   = design_survival
    )

    res <- tryCatch(
      do.call(fn, args),
      error = function(err) {
        msg <- conditionMessage(err)
        if (startsWith(msg, "designr_input_error:")) {
          stop(sprintf(
            "designr_input_error: endpoints: '%s': %s", nm,
            sub("^designr_input_error:\\s*", "", msg)))
        }
        stop(err)
      }
    )

    per_ep[[nm]] <- res
  }

  # --- aggregate total N (max across endpoints) ----------------------------
  ns <- vapply(per_ep, function(r) r$sample_size_total, numeric(1))
  driver <- names(ns)[which.max(ns)]
  total_n <- max(ns)

  per_arm <- .per_arm(total_n, allocation_ratio)

  # --- assemble result ------------------------------------------------------
  inputs <- list(
    endpoints        = lapply(endpoints, function(e) e[setdiff(names(e), "type")]),
    endpoint_types   = vapply(endpoints, function(e) e$type, character(1)),
    strategy         = strategy,
    alpha            = alpha,
    sided            = sided,
    power            = power,
    allocation_ratio = allocation_ratio
  )
  if (strategy == "fixed-sequence") inputs$ordering <- ordering
  if (strategy == "alpha-split")    inputs$alpha_weights <- alpha_weights

  multiplicity <- list(
    strategy        = strategy,
    per_endpoint_alpha = as.list(per_alpha),
    family_alpha    = alpha,
    rationale       = switch(strategy,
      "fixed-sequence" = "Each endpoint tested at full family alpha; gating preserves family-wise alpha by closed testing.",
      "alpha-split"    = "Family alpha partitioned by user-supplied weights; per-endpoint alpha = alpha * w_i.",
      "bonferroni"     = "Equal-weight alpha-split (alpha / k per endpoint).")
  )

  .designr_result(
    sample_size_total   = total_n,
    sample_size_per_arm = per_arm,
    events_total        = NULL,
    boundaries          = NULL,
    timing              = NULL,
    operational         = NULL,
    inputs              = inputs,
    method              = sprintf("design_co_primary[%s]", strategy),
    package_version     = .pkg_version("ClinicalTrialDesign"),
    raw                 = list(
      endpoints    = per_ep,
      driver       = driver,
      multiplicity = multiplicity
    )
  )
}
