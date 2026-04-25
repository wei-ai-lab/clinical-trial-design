#' Group-sequential survival design under NPH (MaxCombo / WLR / AHR)
#'
#' Wrapper over [gsDesign2::gs_design_combo()], [gsDesign2::gs_design_wlr()],
#' and [gsDesign2::gs_design_ahr()] for group-sequential TTE designs under
#' non-proportional hazards (delayed effect, crossing hazards, etc.).
#'
#' @param control_median Control-arm median survival (months).
#' @param delay_months Duration of the "no-effect" period. Set to 0 for PH.
#' @param post_delay_hr Hazard ratio after `delay_months`.
#' @param accrual_rate Enrollment rate (subjects / month).
#' @param accrual_duration Accrual period (months).
#' @param analysis_times Calendar times (months from first enrollment) of the
#'   `k` planned analyses. Last element = study duration.
#' @param dropout_rate Per-month dropout hazard (default 0.001).
#' @param test Which NPH statistic to use at each analysis: `"maxcombo"`
#'   (default), `"wlr"` (Fleming-Harrington weighted log-rank), or
#'   `"ahr"` (average hazard ratio).
#' @param rho,gamma,tau Fleming-Harrington weight parameters. For MaxCombo
#'   these are vectors enumerating the weight combinations tested at each
#'   analysis; for WLR they are scalars.
#' @param alpha,power,sided,allocation_ratio As elsewhere.
#' @param sfu Upper alpha-spending function name. Default `"LDOF"`.
#' @param binding Logical; whether the futility boundary is binding.
#' @return A `designr` result list with `events_total`, `boundaries`, and
#'   `timing` populated.
#' @export
design_gs_survival_nph_combo <- function(control_median,
                                         delay_months,
                                         post_delay_hr,
                                         accrual_rate,
                                         accrual_duration,
                                         analysis_times,
                                         dropout_rate     = 0.001,
                                         test             = c("maxcombo", "wlr", "ahr"),
                                         rho              = c(0, 0, 1),
                                         gamma            = c(0, 1, 0),
                                         tau              = rep(-1, 3),
                                         alpha            = 0.025,
                                         power            = 0.90,
                                         sided            = 1,
                                         allocation_ratio = 1,
                                         sfu              = "LDOF",
                                         binding          = FALSE) {
  check_pos(control_median, "control_median")
  check_nonneg(delay_months, "delay_months")
  check_pos(post_delay_hr, "post_delay_hr")
  check_pos(accrual_rate, "accrual_rate")
  check_pos(accrual_duration, "accrual_duration")
  if (!is.numeric(analysis_times) || length(analysis_times) < 2L ||
      any(analysis_times <= 0) || is.unsorted(analysis_times, strictly = TRUE)) {
    designr_stop("analysis_times",
                 "must be a strictly increasing numeric vector of length >= 2")
  }
  if (analysis_times[1] < accrual_duration) {
    # allowed but unusual; warn via a later check - OK to proceed
  }
  check_nonneg(dropout_rate, "dropout_rate")
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  if (sided != 1L) designr_stop("sided", "NPH combo designs are one-sided only; use sided = 1")
  check_ratio(allocation_ratio)
  sfu_name <- check_spending_fn(sfu, "sfu")
  test <- match.arg(test)
  if (!is.logical(binding) || length(binding) != 1L) {
    designr_stop("binding", "must be a single logical value")
  }

  k <- length(analysis_times)
  beta <- 1 - power
  lambdaC <- log(2) / control_median
  fr_duration <- if (delay_months > 0) c(delay_months, Inf) else c(Inf)
  fr_rates    <- rep(lambdaC, length(fr_duration))
  fr_hr       <- if (delay_months > 0) c(1, post_delay_hr) else c(post_delay_hr)
  fr_dropout  <- rep(dropout_rate, length(fr_duration))

  enroll <- gsDesign2::define_enroll_rate(duration = accrual_duration,
                                          rate     = accrual_rate)
  failr  <- gsDesign2::define_fail_rate(duration     = fr_duration,
                                        fail_rate    = fr_rates,
                                        hr           = fr_hr,
                                        dropout_rate = fr_dropout)

  upar <- list(sf = .resolve_sf(sfu_name), total_spend = alpha)
  lpar <- rep(-Inf, k)

  out <- switch(test,
    "maxcombo" = {
      n_weights <- length(rho)
      if (length(gamma) != n_weights || length(tau) != n_weights) {
        designr_stop("rho",
                     "rho, gamma, and tau must all have the same length")
      }
      fh_test <- do.call(rbind, lapply(seq_len(k), function(i) {
        data.frame(rho = rho, gamma = gamma, tau = tau,
                   test = seq_len(n_weights),
                   analysis = i,
                   analysis_time = analysis_times[i])
      }))
      gsDesign2::gs_design_combo(
        enroll_rate = enroll, fail_rate = failr, fh_test = fh_test,
        alpha = alpha, beta = beta, ratio = allocation_ratio,
        binding = binding,
        upper = gsDesign2::gs_spending_combo, upar = upar,
        lower = gsDesign2::gs_b, lpar = lpar
      )
    },
    "wlr" = {
      weight <- function(x, arm0, arm1) {
        gsDesign2::wlr_weight_fh(x, arm0, arm1,
                                 rho = rho[1], gamma = gamma[1], tau = tau[1])
      }
      gsDesign2::gs_design_wlr(
        enroll_rate = enroll, fail_rate = failr, weight = weight,
        alpha = alpha, beta = beta, ratio = allocation_ratio,
        analysis_time = analysis_times, binding = binding,
        upper = gsDesign2::gs_spending_bound, upar = upar,
        lower = gsDesign2::gs_b, lpar = lpar
      )
    },
    "ahr" = {
      gsDesign2::gs_design_ahr(
        enroll_rate = enroll, fail_rate = failr,
        alpha = alpha, beta = beta, ratio = allocation_ratio,
        analysis_time = analysis_times, binding = binding,
        upper = gsDesign2::gs_spending_bound, upar = upar,
        lower = gsDesign2::gs_b, lpar = lpar
      )
    }
  )

  analysis_df <- as.data.frame(out$analysis)
  bounds_df   <- as.data.frame(
    if (!is.null(out$bound)) out$bound else out$bounds
  )
  upper_rows <- bounds_df[bounds_df$bound == "upper", , drop = FALSE]
  lower_rows <- bounds_df[bounds_df$bound == "lower", , drop = FALSE]

  n_total_max <- as.numeric(analysis_df$n[k])
  events_max  <- as.numeric(analysis_df$event[k])
  n_control <- n_total_max / (1 + allocation_ratio)
  n_treat   <- n_total_max - n_control

  upper_z <- as.numeric(upper_rows$z)
  lower_z <- if (nrow(lower_rows) > 0 && any(is.finite(lower_rows$z))) {
    as.numeric(lower_rows$z)
  } else NULL

  boundaries <- list(
    upper_z = upper_z,
    lower_z = lower_z,
    upper_p = as.numeric(stats::pnorm(-upper_z))
  )
  timing_out <- list(
    analysis_times      = as.numeric(analysis_df$time),
    events_per_analysis = as.numeric(analysis_df$event),
    n_per_analysis      = as.numeric(analysis_df$n)
  )

  .designr_result(
    sample_size_total   = n_total_max,
    sample_size_per_arm = c(control = n_control, treatment = n_treat),
    events_total        = events_max,
    boundaries          = boundaries,
    timing              = timing_out,
    inputs = list(
      control_median = control_median,
      delay_months   = delay_months,
      post_delay_hr  = post_delay_hr,
      accrual_rate   = accrual_rate,
      accrual_duration = accrual_duration,
      analysis_times   = analysis_times,
      dropout_rate     = dropout_rate,
      test = test, rho = rho, gamma = gamma, tau = tau,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      sfu = sfu_name, binding = binding,
      comparison = "superiority"
    ),
    method = sprintf("gsDesign2::gs_design_%s", test),
    package_version = .pkg_version("gsDesign2"),
    raw = list(ahr_schedule = as.data.frame(analysis_df))
  )
}
