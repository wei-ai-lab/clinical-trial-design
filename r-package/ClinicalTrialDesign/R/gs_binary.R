#' Group-sequential two-arm binary endpoint design
#'
#' Thin wrapper combining [gsDesign::gsDesign()] for the boundary + timing
#' structure with [gsDesign::nBinomial()] for the fixed-sample anchor.
#'
#' @param p_control,p_treatment Event rates.
#' @param k Number of analyses (>= 2).
#' @param timing Information fractions at each analysis in (0, 1], length `k`.
#'   Defaults to equal spacing.
#' @param sfu,sfl Upper/lower alpha-spending functions — one of
#'   `"OF"`, `"Pocock"`, `"HSD"`, `"Power"`, `"LDOF"`, `"LDPocock"`, `"none"`.
#' @param sfupar,sflpar Numeric parameters for HSD / Power families. Ignored otherwise.
#' @param test.type gsDesign test.type (1 = efficacy-only, 2 = symmetric,
#'   3 = non-binding futility, 4 = binding futility, …). Default 1.
#' @param alpha,power,sided,allocation_ratio,comparison,ni_margin See [design_fixed_binary()].
#' @return A `designr` result list with `boundaries` and `timing` populated.
#' @export
design_gs_binary <- function(p_control,
                             p_treatment,
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
  check_prob(p_control, "p_control")
  check_prob(p_treatment, "p_treatment")
  k <- check_int(k, "k", lo = 2L, hi = 10L)
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  check_ratio(allocation_ratio)
  comparison <- check_comparison(comparison)
  if (comparison == "equivalence") {
    designr_stop("comparison", "equivalence is not supported for GS binary; use fixed-sample TOST")
  }
  sfu_name <- check_spending_fn(sfu, "sfu")
  sfl_name <- check_spending_fn(sfl, "sfl")
  test.type <- check_int(test.type, "test.type", lo = 1L, hi = 6L)

  if (is.null(timing)) {
    timing <- seq_len(k) / k
  } else {
    if (length(timing) != k || any(timing <= 0) || any(timing > 1) ||
        is.unsorted(timing, strictly = TRUE) || abs(timing[k] - 1) > 1e-9) {
      designr_stop("timing", "must be strictly increasing in (0,1], length k, last = 1")
    }
  }
  beta <- 1 - power

  sfu_fn <- .resolve_sf(sfu_name); sfl_fn <- .resolve_sf(sfl_name)

  gs <- gsDesign::gsDesign(
    k = k, test.type = test.type,
    alpha = alpha, beta = beta, timing = timing,
    sfu = sfu_fn, sfupar = if (is.null(sfupar)) -4 else sfupar,
    sfl = sfl_fn, sflpar = if (is.null(sflpar)) -2 else sflpar
  )

  if (comparison == "superiority") {
    n_fix <- gsDesign::nBinomial(p1 = p_control, p2 = p_treatment,
                                 alpha = alpha, beta = beta,
                                 sided = sided, ratio = allocation_ratio)
  } else {
    if (is.null(ni_margin)) designr_stop("ni_margin",
                                         "required when comparison = 'non-inferiority'")
    check_pos(ni_margin, "ni_margin")
    delta0 <- ni_margin * sign(p_treatment - p_control)
    if (delta0 == 0) delta0 <- ni_margin
    n_fix <- gsDesign::nBinomial(p1 = p_control, p2 = p_treatment,
                                 delta0 = delta0,
                                 alpha = alpha, beta = beta,
                                 sided = 1, ratio = allocation_ratio)
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
      p_control = p_control, p_treatment = p_treatment,
      k = k, timing = timing,
      sfu = sfu_name, sfl = sfl_name, test.type = test.type,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison, ni_margin = ni_margin
    ),
    method          = sprintf("gsDesign::gsDesign (binary, %s)", comparison),
    package_version = .pkg_version("gsDesign")
  )
}

# Map user-facing spending-function names to gsDesign functions.
# OF / Pocock map to the Lan-DeMets spending approximations of the classic
# boundaries; HSD / Power take their sfupar / sflpar numeric parameter.
.resolve_sf <- function(name) {
  switch(name,
         "OF"       = gsDesign::sfLDOF,
         "Pocock"   = gsDesign::sfLDPocock,
         "HSD"      = gsDesign::sfHSD,
         "Power"    = gsDesign::sfPower,
         "LDOF"     = gsDesign::sfLDOF,
         "LDPocock" = gsDesign::sfLDPocock,
         "none"     = NULL,
         gsDesign::sfLDOF)
}
