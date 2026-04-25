#' Fixed-sample time-to-event design under proportional hazards
#'
#' Thin wrapper over [gsDesign::nSurv()] for PH log-rank superiority /
#' non-inferiority.
#'
#' @param control_median Control-arm median survival (same time units as
#'   `accrual_duration` and `followup_duration`).
#' @param hazard_ratio Assumed HR (treatment / control). Must be non-null
#'   for superiority.
#' @param hr_null The HR under the null hypothesis. Defaults to 1 for
#'   superiority and to `ni_hr` for NI.
#' @param accrual_duration,followup_duration,accrual_rate Trial operational
#'   parameters. `accrual_rate` is subjects per time unit; the total planned
#'   enrollment is `accrual_rate * accrual_duration`.
#' @param dropout_rate Annual dropout hazard (`eta` in gsDesign).
#' @param alpha,power,sided Type-I, power, sidedness.
#' @param allocation_ratio,comparison,ni_hr See [design_fixed_binary()].
#'   `ni_hr` (for NI) is the margin on the HR scale, e.g. 1.30.
#'
#' @return A `designr` result list (see [utils_format]); populates
#'   `events_total` and `sample_size_total`.
#' @export
design_fixed_survival_ph <- function(control_median,
                                     hazard_ratio,
                                     hr_null             = 1,
                                     accrual_duration    = 12,
                                     followup_duration   = 12,
                                     accrual_rate        = NULL,
                                     dropout_rate        = 0,
                                     alpha               = 0.025,
                                     power               = 0.90,
                                     sided               = 1,
                                     allocation_ratio    = 1,
                                     comparison          = "superiority",
                                     ni_hr               = NULL) {
  check_pos(control_median, "control_median")
  check_pos(hazard_ratio, "hazard_ratio")
  check_pos(hr_null, "hr_null")
  check_pos(accrual_duration, "accrual_duration")
  check_nonneg(followup_duration, "followup_duration")
  check_nonneg(dropout_rate, "dropout_rate")
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  check_ratio(allocation_ratio)
  comparison <- check_comparison(comparison)

  if (comparison == "equivalence") {
    designr_stop("comparison",
                 "equivalence is not supported for survival PH designs; use superiority or non-inferiority")
  }
  if (comparison == "non-inferiority") {
    if (is.null(ni_hr)) designr_stop("ni_hr",
                                     "required when comparison = 'non-inferiority'")
    check_pos(ni_hr, "ni_hr")
    hr_null <- ni_hr
  }

  lambdaC <- log(2) / control_median
  R   <- accrual_duration
  mf  <- followup_duration
  T   <- R + mf
  gamma <- if (is.null(accrual_rate)) 1 else accrual_rate
  beta <- 1 - power

  out <- gsDesign::nSurv(
    lambdaC = lambdaC,
    hr      = hazard_ratio,
    hr0     = hr_null,
    eta     = dropout_rate,
    gamma   = gamma,
    R       = R,
    T       = T,
    minfup  = mf,
    ratio   = allocation_ratio,
    alpha   = alpha,
    beta    = beta,
    sided   = sided
  )
  n_total <- as.numeric(out$n)
  d_total <- as.numeric(out$d)
  n_control <- n_total / (1 + allocation_ratio)
  n_treat   <- n_total - n_control

  .designr_result(
    sample_size_total   = n_total,
    sample_size_per_arm = c(control = n_control, treatment = n_treat),
    events_total        = d_total,
    timing              = list(
      accrual_duration  = R,
      followup_duration = mf,
      total_duration    = T,
      accrual_rate      = if (is.null(accrual_rate)) out$gamma else accrual_rate
    ),
    inputs = list(
      control_median = control_median,
      hazard_ratio   = hazard_ratio,
      hr_null        = hr_null,
      accrual_duration  = accrual_duration,
      followup_duration = followup_duration,
      accrual_rate      = accrual_rate,
      dropout_rate      = dropout_rate,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison, ni_hr = ni_hr
    ),
    method          = sprintf("gsDesign::nSurv (%s)", comparison),
    package_version = .pkg_version("gsDesign"),
    raw             = list(eta = out$eta, gamma = out$gamma)
  )
}
