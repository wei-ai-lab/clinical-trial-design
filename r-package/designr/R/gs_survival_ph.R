#' Group-sequential survival design under proportional hazards
#'
#' Wrapper around [gsDesign::gsSurv()]. Computes max events, total sample
#' size, and per-analysis event counts + Z-boundaries for a group-sequential
#' log-rank test under PH.
#'
#' @param control_median Control-arm median survival (months).
#' @param hazard_ratio Target treatment / control hazard ratio. For superiority,
#'   must be != 1. For non-inferiority, the assumed true HR (often 1).
#' @param accrual_rate Enrollment rate (subjects / month).
#' @param accrual_duration Accrual period (months).
#' @param followup_duration Minimum follow-up after last enrollment (months).
#'   Total study duration = accrual_duration + followup_duration.
#' @param dropout_rate Per-month dropout hazard (default 0.001).
#' @param k,timing,sfu,sfl,sfupar,sflpar,test.type See [design_gs_binary()].
#' @param alpha,power,sided,allocation_ratio,comparison,ni_hr,hr_null Standard
#'   design parameters. For `comparison = "non-inferiority"`, either
#'   `hr_null` (preferred: the HR on the null side, e.g. 1.3) or `ni_hr`
#'   (alias) must be provided.
#' @return A `designr` result list with `events_total`, `boundaries`, and
#'   `timing` populated.
#' @export
design_gs_survival_ph <- function(control_median,
                                  hazard_ratio,
                                  accrual_rate,
                                  accrual_duration,
                                  followup_duration,
                                  dropout_rate     = 0.001,
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
                                  ni_hr            = NULL,
                                  hr_null          = NULL) {
  check_pos(control_median, "control_median")
  check_pos(hazard_ratio, "hazard_ratio")
  check_pos(accrual_rate, "accrual_rate")
  check_pos(accrual_duration, "accrual_duration")
  check_pos(followup_duration, "followup_duration")
  check_nonneg(dropout_rate, "dropout_rate")
  k <- check_int(k, "k", lo = 2L, hi = 10L)
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  check_ratio(allocation_ratio)
  comparison <- check_comparison(comparison)
  if (comparison == "equivalence") {
    designr_stop("comparison", "equivalence is not supported for survival designs")
  }
  sfu_name <- check_spending_fn(sfu, "sfu")
  sfl_name <- check_spending_fn(sfl, "sfl")
  test.type <- check_int(test.type, "test.type", lo = 1L, hi = 6L)

  if (is.null(timing)) timing <- seq_len(k) / k
  else if (length(timing) != k || any(timing <= 0) || any(timing > 1) ||
           is.unsorted(timing, strictly = TRUE) || abs(timing[k] - 1) > 1e-9) {
    designr_stop("timing", "must be strictly increasing in (0,1], length k, last = 1")
  }

  if (comparison == "superiority") {
    if (isTRUE(all.equal(hazard_ratio, 1))) {
      designr_stop("hazard_ratio", "must be != 1 for a superiority test")
    }
    hr0 <- 1
  } else {
    margin <- if (!is.null(hr_null)) hr_null else ni_hr
    if (is.null(margin)) designr_stop("hr_null",
                                      "required when comparison = 'non-inferiority'")
    check_pos(margin, "hr_null")
    if (isTRUE(all.equal(margin, 1))) {
      designr_stop("hr_null", "must differ from 1 to define a non-inferiority margin")
    }
    hr0 <- margin
  }

  beta <- 1 - power
  lambdaC <- log(2) / control_median
  study_T <- accrual_duration + followup_duration

  gs <- gsDesign::gsSurv(
    k = k, test.type = test.type, alpha = alpha, beta = beta, sided = sided,
    timing = timing,
    sfu = .resolve_sf(sfu_name), sfupar = if (is.null(sfupar)) -4 else sfupar,
    sfl = .resolve_sf(sfl_name), sflpar = if (is.null(sflpar)) -2 else sflpar,
    lambdaC = lambdaC, hr = hazard_ratio, hr0 = hr0,
    eta = dropout_rate, gamma = accrual_rate,
    R = accrual_duration, T = study_T, minfup = followup_duration,
    ratio = allocation_ratio
  )

  n_control_by_analysis <- as.numeric(gs$eNC[, 1])
  n_treat_by_analysis   <- as.numeric(gs$eNE[, 1])
  d_control_by_analysis <- as.numeric(gs$eDC[, 1])
  d_treat_by_analysis   <- as.numeric(gs$eDE[, 1])

  n_total_max <- n_control_by_analysis[k] + n_treat_by_analysis[k]
  events_max  <- d_control_by_analysis[k] + d_treat_by_analysis[k]
  events_by_analysis <- d_control_by_analysis + d_treat_by_analysis

  boundaries <- list(
    upper_z = as.numeric(gs$upper$bound),
    lower_z = if (!is.null(gs$lower)) as.numeric(gs$lower$bound) else NULL,
    upper_p = as.numeric(stats::pnorm(-gs$upper$bound))
  )
  timing_out <- list(
    information_fraction = as.numeric(gs$timing),
    events_per_analysis  = events_by_analysis,
    analysis_times       = as.numeric(gs$T)
  )

  .designr_result(
    sample_size_total   = n_total_max,
    sample_size_per_arm = c(control = n_control_by_analysis[k],
                            treatment = n_treat_by_analysis[k]),
    events_total        = events_max,
    boundaries          = boundaries,
    timing              = timing_out,
    inputs = list(
      control_median = control_median,
      hazard_ratio   = hazard_ratio,
      hr_null        = hr0,
      accrual_rate   = accrual_rate,
      accrual_duration  = accrual_duration,
      followup_duration = followup_duration,
      dropout_rate      = dropout_rate,
      k = k, timing = timing,
      sfu = sfu_name, sfl = sfl_name, test.type = test.type,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison
    ),
    method          = sprintf("gsDesign::gsSurv (PH, %s)", comparison),
    package_version = .pkg_version("gsDesign")
  )
}
