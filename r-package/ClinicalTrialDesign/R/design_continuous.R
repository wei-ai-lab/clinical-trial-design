#' Two-arm continuous endpoint design (fixed-sample or group-sequential)
#'
#' Unified entry point. Backends:
#' \itemize{
#'   \item `design_class = "fixed"` → [gsDesign::nNormal()].
#'   \item `design_class = "group-sequential"` → [gsDesign::gsDesign()] +
#'     [gsDesign::nNormal()].
#' }
#'
#' @param mean_diff Assumed mean difference (treatment − control).
#' @param sd Pooled SD on the per-subject scale.
#' @param design_class One of `"fixed"` or `"group-sequential"`.
#' @param comparison One of `"superiority"`, `"non-inferiority"`, `"equivalence"`.
#'   Equivalence is only supported with `design_class = "fixed"`.
#' @param alpha,power,sided,allocation_ratio Standard design parameters.
#' @param ni_margin,equiv_margin Margins on the mean-difference scale (required
#'   for the corresponding `comparison`).
#' @param k,timing,sfu,sfl,sfupar,sflpar,test.type Group-sequential parameters.
#' @param operational Optional named list of operational kernel inputs (any 0–4 of
#'   `accrual_rate`, `accrual_duration`, `follow_up_duration`,
#'   `total_trial_duration`). When supplied, [solve_operational] fills in the
#'   missing values and attaches them to the result as `$operational`.
#'
#' @return A unified result list (see [utils_format]).
#' @export
design_continuous <- function(mean_diff,
                              sd,
                              design_class     = "fixed",
                              comparison       = "superiority",
                              alpha            = 0.05,
                              power            = 0.80,
                              sided            = 2,
                              allocation_ratio = 1,
                              ni_margin        = NULL,
                              equiv_margin     = NULL,
                              k                = 2,
                              timing           = NULL,
                              sfu              = "LDOF",
                              sfl              = "LDOF",
                              sfupar           = NULL,
                              sflpar           = NULL,
                              test.type        = 1,
                              operational      = NULL) {
  design_class <- check_design_class(design_class)
  res <- if (design_class == "fixed") {
    .design_continuous_fixed(mean_diff, sd, alpha, power, sided,
                             allocation_ratio, comparison, ni_margin, equiv_margin)
  } else {
    .design_continuous_gs(mean_diff, sd, k, timing, sfu, sfl,
                          sfupar, sflpar, test.type, alpha, power, sided,
                          allocation_ratio, comparison, ni_margin)
  }
  if (!is.null(operational)) {
    res$operational <- do.call(solve_operational,
      c(list(target_n = res$sample_size_total,
             endpoint_type = "continuous",
             allocation_ratio = allocation_ratio),
        operational))
  }
  res
}

.design_continuous_fixed <- function(mean_diff, sd,
                                     alpha            = 0.05,
                                     power            = 0.80,
                                     sided            = 2,
                                     allocation_ratio = 1,
                                     comparison       = "superiority",
                                     ni_margin        = NULL,
                                     equiv_margin     = NULL) {
  if (!is.numeric(mean_diff) || length(mean_diff) != 1L || is.na(mean_diff)) {
    designr_stop("mean_diff", "must be a single finite numeric")
  }
  check_pos(sd, "sd")
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  check_ratio(allocation_ratio)
  comparison <- check_comparison(comparison)
  beta <- 1 - power

  if (comparison == "superiority") {
    if (isTRUE(all.equal(mean_diff, 0))) {
      designr_stop("mean_diff", "must be non-zero for a superiority test")
    }
    out <- gsDesign::nNormal(
      delta1 = mean_diff, sd = sd, sd2 = sd,
      alpha = alpha, beta = beta, sided = sided,
      ratio = allocation_ratio, outtype = 2
    )
    n_control <- as.numeric(out["n1"])
    n_treat   <- as.numeric(out["n2"])
    method    <- "gsDesign::nNormal (superiority)"

  } else if (comparison == "non-inferiority") {
    if (is.null(ni_margin)) designr_stop("ni_margin",
                                         "required when comparison = 'non-inferiority'")
    check_pos(ni_margin, "ni_margin")
    delta0 <- ni_margin * sign(mean_diff)
    if (delta0 == 0) delta0 <- ni_margin
    out <- gsDesign::nNormal(
      delta1 = mean_diff, delta0 = delta0, sd = sd, sd2 = sd,
      alpha = alpha, beta = beta, sided = 1,
      ratio = allocation_ratio, outtype = 2
    )
    n_control <- as.numeric(out["n1"])
    n_treat   <- as.numeric(out["n2"])
    method    <- "gsDesign::nNormal (non-inferiority)"

  } else {
    if (is.null(equiv_margin)) designr_stop("equiv_margin",
                                            "required when comparison = 'equivalence'")
    check_pos(equiv_margin, "equiv_margin")
    n_lo <- gsDesign::nNormal(
      delta1 = mean_diff, delta0 = -equiv_margin, sd = sd, sd2 = sd,
      alpha = alpha / 2, beta = beta, sided = 1,
      ratio = allocation_ratio, outtype = 2
    )
    n_hi <- gsDesign::nNormal(
      delta1 = mean_diff, delta0 = equiv_margin, sd = sd, sd2 = sd,
      alpha = alpha / 2, beta = beta, sided = 1,
      ratio = allocation_ratio, outtype = 2
    )
    n_control <- max(as.numeric(n_lo["n1"]), as.numeric(n_hi["n1"]))
    n_treat   <- max(as.numeric(n_lo["n2"]), as.numeric(n_hi["n2"]))
    method    <- "gsDesign::nNormal (equivalence TOST)"
  }

  n_total <- n_control + n_treat
  .designr_result(
    sample_size_total   = n_total,
    sample_size_per_arm = c(control = n_control, treatment = n_treat),
    inputs = list(
      mean_diff = mean_diff, sd = sd,
      design_class = "fixed",
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison,
      ni_margin = ni_margin, equiv_margin = equiv_margin
    ),
    method          = method,
    package_version = .pkg_version("gsDesign")
  )
}

.design_continuous_gs <- function(mean_diff, sd,
                                  k                = 2,
                                  timing           = NULL,
                                  sfu              = "LDOF",
                                  sfl              = "LDOF",
                                  sfupar           = NULL,
                                  sflpar           = NULL,
                                  test.type        = 1,
                                  alpha            = 0.025,
                                  power            = 0.90,
                                  sided            = 1,
                                  allocation_ratio = 1,
                                  comparison       = "superiority",
                                  ni_margin        = NULL) {
  if (!is.numeric(mean_diff) || length(mean_diff) != 1L || is.na(mean_diff)) {
    designr_stop("mean_diff", "must be a single finite numeric")
  }
  check_pos(sd, "sd")
  k <- check_int(k, "k", lo = 2L, hi = 10L)
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  check_ratio(allocation_ratio)
  comparison <- check_comparison(comparison)
  if (comparison == "equivalence") {
    designr_stop("comparison",
                 "equivalence is not supported for group-sequential continuous; use design_class = 'fixed'")
  }
  sfu_name <- check_spending_fn(sfu, "sfu")
  sfl_name <- check_spending_fn(sfl, "sfl")
  test.type <- check_int(test.type, "test.type", lo = 1L, hi = 6L)

  if (is.null(timing)) timing <- seq_len(k) / k
  else if (length(timing) != k || any(timing <= 0) || any(timing > 1) ||
           is.unsorted(timing, strictly = TRUE) || abs(timing[k] - 1) > 1e-9) {
    designr_stop("timing", "must be strictly increasing in (0,1], length k, last = 1")
  }
  beta <- 1 - power

  gs <- gsDesign::gsDesign(
    k = k, test.type = test.type, alpha = alpha, beta = beta, timing = timing,
    sfu = .resolve_sf(sfu_name), sfupar = if (is.null(sfupar)) -4 else sfupar,
    sfl = .resolve_sf(sfl_name), sflpar = if (is.null(sflpar)) -2 else sflpar
  )
  if (comparison == "superiority") {
    if (isTRUE(all.equal(mean_diff, 0))) {
      designr_stop("mean_diff", "must be non-zero for a superiority test")
    }
    n_fix <- gsDesign::nNormal(delta1 = mean_diff, sd = sd, sd2 = sd,
                               alpha = alpha, beta = beta, sided = sided,
                               ratio = allocation_ratio)
  } else {
    if (is.null(ni_margin)) designr_stop("ni_margin",
                                         "required when comparison = 'non-inferiority'")
    check_pos(ni_margin, "ni_margin")
    delta0 <- ni_margin * sign(mean_diff)
    if (delta0 == 0) delta0 <- ni_margin
    n_fix <- gsDesign::nNormal(delta1 = mean_diff, delta0 = delta0,
                               sd = sd, sd2 = sd,
                               alpha = alpha, beta = beta, sided = 1,
                               ratio = allocation_ratio)
  }
  n_total_max <- n_fix * gs$n.I[k]
  n_per_analysis <- n_fix * gs$n.I
  n_control <- n_total_max / (1 + allocation_ratio)
  n_treat   <- n_total_max - n_control

  boundaries <- list(
    upper_z = as.numeric(gs$upper$bound),
    lower_z = if (!is.null(gs$lower)) as.numeric(gs$lower$bound) else NULL,
    upper_p = as.numeric(stats::pnorm(-gs$upper$bound))
  )
  timing_out <- list(
    information_fraction = as.numeric(gs$timing),
    n_per_analysis       = as.numeric(n_per_analysis)
  )

  .designr_result(
    sample_size_total   = n_total_max,
    sample_size_per_arm = c(control = n_control, treatment = n_treat),
    boundaries          = boundaries,
    timing              = timing_out,
    inputs = list(
      mean_diff = mean_diff, sd = sd,
      design_class = "group-sequential",
      k = k, timing = timing,
      sfu = sfu_name, sfl = sfl_name, test.type = test.type,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison, ni_margin = ni_margin
    ),
    method          = sprintf("gsDesign::gsDesign (continuous, %s)", comparison),
    package_version = .pkg_version("gsDesign")
  )
}
