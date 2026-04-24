#' Fixed-sample survival design using RMST
#'
#' Thin wrapper over [gsDesign2::fixed_design_rmst()]. Tests a difference
#' in restricted mean survival time at landmark time `tau`. Natural for
#' NPH patterns where the mean effect over `[0, tau]` is the quantity of
#' clinical interest.
#'
#' @param control_median Control-arm median survival (months).
#' @param delay_months Duration of HR=1 period (for delayed-effect NPH).
#' @param post_delay_hr HR after `delay_months`.
#' @param accrual_rate Enrollment rate (subjects / month).
#' @param accrual_duration,study_duration Same units.
#' @param tau Landmark time for RMST (default = study_duration).
#' @param dropout_rate,alpha,power,sided,allocation_ratio As elsewhere.
#' @return A `designr` result list.
#' @export
design_fixed_survival_rmst <- function(control_median,
                                       delay_months,
                                       post_delay_hr,
                                       accrual_rate,
                                       accrual_duration,
                                       study_duration,
                                       tau              = NULL,
                                       dropout_rate     = 0.001,
                                       alpha            = 0.025,
                                       power            = 0.90,
                                       sided            = 1,
                                       allocation_ratio = 1) {
  check_pos(control_median, "control_median")
  check_nonneg(delay_months, "delay_months")
  check_pos(post_delay_hr, "post_delay_hr")
  check_pos(accrual_rate, "accrual_rate")
  check_pos(accrual_duration, "accrual_duration")
  check_pos(study_duration, "study_duration")
  if (study_duration <= accrual_duration) {
    designr_stop("study_duration", "must exceed accrual_duration")
  }
  if (!is.null(tau)) check_pos(tau, "tau")
  check_nonneg(dropout_rate, "dropout_rate")
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  if (sided != 1L) designr_stop("sided", "RMST is one-sided only; use sided = 1")
  check_ratio(allocation_ratio)

  lambdaC <- log(2) / control_median
  fr_duration <- if (delay_months > 0) c(delay_months, Inf) else c(Inf)
  fr_rates    <- rep(lambdaC, length(fr_duration))
  fr_hr       <- if (delay_months > 0) c(1, post_delay_hr) else c(post_delay_hr)
  fr_dropout  <- rep(dropout_rate, length(fr_duration))

  enroll <- gsDesign2::define_enroll_rate(duration = accrual_duration, rate = accrual_rate)
  failr  <- gsDesign2::define_fail_rate(duration = fr_duration, fail_rate = fr_rates,
                                        hr = fr_hr, dropout_rate = fr_dropout)

  out <- gsDesign2::fixed_design_rmst(
    alpha = alpha, power = power, ratio = allocation_ratio,
    study_duration = study_duration,
    enroll_rate = enroll, fail_rate = failr, tau = tau
  )
  n_total <- as.numeric(out$analysis$n)
  d_total <- as.numeric(out$analysis$event)
  n_control <- n_total / (1 + allocation_ratio)
  n_treat   <- n_total - n_control

  .designr_result(
    sample_size_total   = n_total,
    sample_size_per_arm = c(control = n_control, treatment = n_treat),
    events_total        = d_total,
    timing              = list(
      accrual_duration  = accrual_duration,
      study_duration    = study_duration,
      followup_duration = study_duration - accrual_duration,
      tau               = if (is.null(tau)) study_duration else tau,
      bound_z           = as.numeric(out$analysis$bound)
    ),
    inputs = list(
      control_median = control_median,
      delay_months   = delay_months,
      post_delay_hr  = post_delay_hr,
      accrual_rate   = accrual_rate,
      accrual_duration = accrual_duration,
      study_duration   = study_duration,
      tau = tau,
      dropout_rate = dropout_rate,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = "superiority"
    ),
    method          = "gsDesign2::fixed_design_rmst",
    package_version = .pkg_version("gsDesign2")
  )
}
