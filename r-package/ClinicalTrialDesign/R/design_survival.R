#' Two-arm time-to-event design (fixed-sample or group-sequential)
#'
#' Unified entry point for survival designs. The `model` parameter selects the
#' underlying statistical method; `design_class` selects fixed-sample vs.
#' group-sequential.
#'
#' Supported (model, design_class) combinations:
#' \tabular{lll}{
#'   \strong{model}      \tab \strong{fixed}                     \tab \strong{group-sequential} \cr
#'   \code{"ph"}         \tab gsDesign::nSurv                    \tab gsDesign::gsSurv \cr
#'   \code{"maxcombo"}   \tab gsDesign2::fixed_design_maxcombo   \tab gsDesign2::gs_design_combo \cr
#'   \code{"rmst"}       \tab gsDesign2::fixed_design_rmst       \tab not yet supported \cr
#'   \code{"milestone"}  \tab gsDesign2::fixed_design_milestone  \tab not yet supported \cr
#'   \code{"wlr"}        \tab not yet supported                  \tab gsDesign2::gs_design_wlr \cr
#'   \code{"ahr"}        \tab not yet supported                  \tab gsDesign2::gs_design_ahr \cr
#' }
#'
#' Operational parameters: durations are always decomposed into
#' `accrual_duration` + `followup_duration`. Total study duration
#' (`study_duration = accrual_duration + followup_duration`) is reported
#' in the result's `timing` block but never an input.
#'
#' @param model One of `"ph"`, `"maxcombo"`, `"rmst"`, `"milestone"`, `"wlr"`, `"ahr"`.
#' @param design_class One of `"fixed"` or `"group-sequential"`.
#' @param control_median Control-arm median survival (months).
#' @param hazard_ratio (PH only) target HR.
#' @param hr_null,ni_hr (PH only) HR under the null. For NI, supply `ni_hr` or `hr_null`.
#' @param delay_months (NPH models) duration of HR=1 period preceding the effect.
#' @param post_delay_hr (NPH models) HR after `delay_months`.
#' @param accrual_rate Enrollment rate (subjects / month). Required except for
#'   PH fixed (where it defaults to 1 = "rate-free" sizing).
#' @param accrual_duration Accrual period (months).
#' @param followup_duration Minimum follow-up after last enrollment (months).
#' @param dropout_rate Per-month dropout hazard.
#' @param tau (RMST / milestone) landmark time. Defaults to total study duration.
#' @param rho,gamma,tau_fh (MaxCombo / WLR) Fleming-Harrington weight parameters.
#' @param k,timing,sfu,sfl,sfupar,sflpar,test.type (PH GS) standard GS params.
#' @param analysis_times (NPH GS) calendar times of `k` planned analyses; last
#'   element = total study duration.
#' @param binding (NPH GS) whether the futility boundary is binding.
#' @param alpha,power,sided,allocation_ratio,comparison Standard design params.
#' @param operational Optional named list of operational kernel inputs (any 0–4 of
#'   `accrual_rate`, `accrual_duration`, `follow_up_duration`,
#'   `total_trial_duration`). When supplied, [solve_operational] fills in the
#'   missing values and attaches them to the result as `$operational`. For
#'   survival, `target_events` from the design ties the system; supplying
#'   only `accrual_rate` lets the solver pin `follow_up_duration` via uniroot.
#'
#' @return A unified result list (see [utils_format]).
#' @export
design_survival <- function(model              = "ph",
                            design_class       = "fixed",
                            control_median,
                            hazard_ratio       = NULL,
                            hr_null            = NULL,
                            ni_hr              = NULL,
                            delay_months       = 0,
                            post_delay_hr      = NULL,
                            accrual_rate       = NULL,
                            accrual_duration   = 12,
                            followup_duration  = 12,
                            dropout_rate       = 0,
                            tau                = NULL,
                            rho                = c(0, 0, 1),
                            gamma              = c(0, 1, 0),
                            tau_fh             = NULL,
                            k                  = 2,
                            timing             = NULL,
                            sfu                = "LDOF",
                            sfl                = "LDOF",
                            sfupar             = NULL,
                            sflpar             = NULL,
                            test.type          = 1,
                            analysis_times     = NULL,
                            binding            = FALSE,
                            alpha              = 0.025,
                            power              = 0.90,
                            sided              = 1,
                            allocation_ratio   = 1,
                            comparison         = "superiority",
                            operational        = NULL,
                            reasoning_chain    = NULL) {
  model <- check_survival_model(model)
  design_class <- check_design_class(design_class)
  reasoning_chain <- check_reasoning_chain(reasoning_chain)
  combo_label <- sprintf("(model='%s', design_class='%s')", model, design_class)

  # Branch table.
  res <- if (model == "ph" && design_class == "fixed") {
    .design_survival_ph_fixed(control_median, hazard_ratio, hr_null, ni_hr,
                              accrual_duration, followup_duration, accrual_rate,
                              dropout_rate, alpha, power, sided,
                              allocation_ratio, comparison)

  } else if (model == "ph" && design_class == "group-sequential") {
    .design_survival_ph_gs(control_median, hazard_ratio, accrual_rate,
                           accrual_duration, followup_duration, dropout_rate,
                           k, timing, sfu, sfl, sfupar, sflpar, test.type,
                           alpha, power, sided, allocation_ratio,
                           comparison, ni_hr, hr_null)

  } else if (model == "maxcombo" && design_class == "fixed") {
    .design_survival_nph_fixed("maxcombo",
                               control_median, delay_months, post_delay_hr,
                               accrual_rate, accrual_duration, followup_duration,
                               dropout_rate, alpha, power, sided,
                               allocation_ratio, rho, gamma, tau_fh, tau,
                               comparison)

  } else if (model == "rmst" && design_class == "fixed") {
    .design_survival_nph_fixed("rmst",
                               control_median, delay_months, post_delay_hr,
                               accrual_rate, accrual_duration, followup_duration,
                               dropout_rate, alpha, power, sided,
                               allocation_ratio, rho, gamma, tau_fh, tau,
                               comparison)

  } else if (model == "milestone" && design_class == "fixed") {
    .design_survival_nph_fixed("milestone",
                               control_median, delay_months, post_delay_hr,
                               accrual_rate, accrual_duration, followup_duration,
                               dropout_rate, alpha, power, sided,
                               allocation_ratio, rho, gamma, tau_fh, tau,
                               comparison)

  } else if (model %in% c("maxcombo", "wlr", "ahr") &&
             design_class == "group-sequential") {
    .design_survival_nph_gs(model, control_median, delay_months, post_delay_hr,
                            accrual_rate, accrual_duration, analysis_times,
                            dropout_rate, rho, gamma, tau_fh,
                            alpha, power, sided, allocation_ratio,
                            sfu, binding, comparison)

  } else {
    designr_stop("model",
                 sprintf("combination %s is not yet supported", combo_label))
  }

  if (!is.null(operational)) {
    hr_for_solver <- if (!is.null(hazard_ratio)) hazard_ratio else post_delay_hr
    res$operational <- do.call(solve_operational,
      c(list(target_n               = res$sample_size_total,
             target_events          = res$events_total,
             endpoint_type          = "survival",
             control_median         = control_median,
             hazard_ratio           = hr_for_solver,
             allocation_ratio       = allocation_ratio,
             dropout_rate_per_month = dropout_rate),
        operational))
  }
  res$reasoning_chain <- reasoning_chain
  res
}

# ---- PH fixed -------------------------------------------------------

.design_survival_ph_fixed <- function(control_median, hazard_ratio, hr_null, ni_hr,
                                      accrual_duration, followup_duration,
                                      accrual_rate, dropout_rate,
                                      alpha, power, sided, allocation_ratio,
                                      comparison) {
  check_pos(control_median, "control_median")
  if (is.null(hazard_ratio)) designr_stop("hazard_ratio", "required for PH model")
  check_pos(hazard_ratio, "hazard_ratio")
  if (is.null(hr_null)) hr_null <- 1
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
                 "equivalence is not supported for survival PH; use superiority or non-inferiority")
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
    lambdaC = lambdaC, hr = hazard_ratio, hr0 = hr_null,
    eta = dropout_rate, gamma = gamma,
    R = R, T = T, minfup = mf,
    ratio = allocation_ratio, alpha = alpha, beta = beta, sided = sided
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
      study_duration    = T,
      accrual_rate      = if (is.null(accrual_rate)) out$gamma else accrual_rate
    ),
    inputs = list(
      model = "ph", design_class = "fixed",
      control_median = control_median,
      hazard_ratio   = hazard_ratio, hr_null = hr_null,
      accrual_duration = accrual_duration,
      followup_duration = followup_duration,
      accrual_rate = accrual_rate, dropout_rate = dropout_rate,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison, ni_hr = ni_hr
    ),
    method          = sprintf("gsDesign::nSurv (PH, %s)", comparison),
    package_version = .pkg_version("gsDesign"),
    raw             = list(eta = out$eta, gamma = out$gamma)
  )
}

# ---- PH GS ----------------------------------------------------------

.design_survival_ph_gs <- function(control_median, hazard_ratio, accrual_rate,
                                   accrual_duration, followup_duration,
                                   dropout_rate, k, timing, sfu, sfl,
                                   sfupar, sflpar, test.type,
                                   alpha, power, sided, allocation_ratio,
                                   comparison, ni_hr, hr_null) {
  check_pos(control_median, "control_median")
  if (is.null(hazard_ratio)) designr_stop("hazard_ratio", "required for PH model")
  check_pos(hazard_ratio, "hazard_ratio")
  if (is.null(accrual_rate)) designr_stop("accrual_rate",
                                          "required for group-sequential PH")
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
    analysis_times       = as.numeric(gs$T),
    accrual_duration     = accrual_duration,
    followup_duration    = followup_duration,
    study_duration       = study_T
  )

  .designr_result(
    sample_size_total   = n_total_max,
    sample_size_per_arm = c(control = n_control_by_analysis[k],
                            treatment = n_treat_by_analysis[k]),
    events_total        = events_max,
    boundaries          = boundaries,
    timing              = timing_out,
    inputs = list(
      model = "ph", design_class = "group-sequential",
      control_median = control_median, hazard_ratio = hazard_ratio,
      hr_null = hr0,
      accrual_rate = accrual_rate,
      accrual_duration = accrual_duration,
      followup_duration = followup_duration,
      dropout_rate = dropout_rate,
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

# ---- NPH fixed (maxcombo / rmst / milestone) ------------------------

.design_survival_nph_fixed <- function(model,
                                       control_median, delay_months, post_delay_hr,
                                       accrual_rate, accrual_duration, followup_duration,
                                       dropout_rate,
                                       alpha, power, sided, allocation_ratio,
                                       rho, gamma, tau_fh, tau,
                                       comparison) {
  check_pos(control_median, "control_median")
  check_nonneg(delay_months, "delay_months")
  if (is.null(post_delay_hr)) designr_stop("post_delay_hr",
                                           "required for NPH models")
  check_pos(post_delay_hr, "post_delay_hr")
  if (is.null(accrual_rate)) designr_stop("accrual_rate",
                                          "required for NPH fixed designs")
  check_pos(accrual_rate, "accrual_rate")
  check_pos(accrual_duration, "accrual_duration")
  check_pos(followup_duration, "followup_duration")
  check_nonneg(dropout_rate, "dropout_rate")
  if (!is.null(tau)) check_pos(tau, "tau")
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  if (sided != 1L) {
    designr_stop("sided",
                 sprintf("%s is one-sided only; use sided = 1", model))
  }
  check_ratio(allocation_ratio)
  if (!identical(comparison, "superiority")) {
    designr_stop("comparison",
                 sprintf("%s NPH fixed designs only support superiority", model))
  }

  study_duration <- accrual_duration + followup_duration
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

  if (model == "maxcombo") {
    if (is.null(tau_fh)) tau_fh <- rep(-1, length(rho))
    if (length(rho) != length(gamma) || length(rho) != length(tau_fh)) {
      designr_stop("rho", "rho, gamma, and tau_fh must all have the same length")
    }
    out <- gsDesign2::fixed_design_maxcombo(
      alpha = alpha, power = power, ratio = allocation_ratio,
      study_duration = study_duration,
      enroll_rate = enroll, fail_rate = failr,
      rho = rho, gamma = gamma, tau = tau_fh
    )
    method_name <- "gsDesign2::fixed_design_maxcombo"
    raw_extra <- list(
      display = attr(out, "design_display"),
      rho = rho, gamma = gamma, tau = tau_fh
    )
  } else if (model == "rmst") {
    out <- gsDesign2::fixed_design_rmst(
      alpha = alpha, power = power, ratio = allocation_ratio,
      study_duration = study_duration,
      enroll_rate = enroll, fail_rate = failr, tau = tau
    )
    method_name <- "gsDesign2::fixed_design_rmst"
    raw_extra <- NULL
  } else {
    out <- gsDesign2::fixed_design_milestone(
      alpha = alpha, power = power, ratio = allocation_ratio,
      enroll_rate = enroll, fail_rate = failr,
      study_duration = study_duration, tau = tau
    )
    method_name <- "gsDesign2::fixed_design_milestone"
    raw_extra <- NULL
  }

  n_total <- as.numeric(out$analysis$n)
  d_total <- as.numeric(out$analysis$event)
  n_control <- n_total / (1 + allocation_ratio)
  n_treat   <- n_total - n_control

  timing_out <- list(
    accrual_duration  = accrual_duration,
    followup_duration = followup_duration,
    study_duration    = study_duration,
    bound_z           = as.numeric(out$analysis$bound)
  )
  if (model %in% c("rmst", "milestone")) {
    timing_out$tau <- if (is.null(tau)) study_duration else tau
  }

  .designr_result(
    sample_size_total   = n_total,
    sample_size_per_arm = c(control = n_control, treatment = n_treat),
    events_total        = d_total,
    timing              = timing_out,
    inputs = list(
      model = model, design_class = "fixed",
      control_median = control_median,
      delay_months   = delay_months,
      post_delay_hr  = post_delay_hr,
      accrual_rate = accrual_rate,
      accrual_duration = accrual_duration,
      followup_duration = followup_duration,
      dropout_rate = dropout_rate,
      tau = tau, rho = rho, gamma = gamma, tau_fh = tau_fh,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = "superiority"
    ),
    method          = method_name,
    package_version = .pkg_version("gsDesign2"),
    raw             = raw_extra
  )
}

# ---- NPH GS (maxcombo / wlr / ahr) ---------------------------------

.design_survival_nph_gs <- function(model,
                                    control_median, delay_months, post_delay_hr,
                                    accrual_rate, accrual_duration, analysis_times,
                                    dropout_rate, rho, gamma, tau_fh,
                                    alpha, power, sided, allocation_ratio,
                                    sfu, binding, comparison) {
  check_pos(control_median, "control_median")
  check_nonneg(delay_months, "delay_months")
  if (is.null(post_delay_hr)) designr_stop("post_delay_hr",
                                           "required for NPH models")
  check_pos(post_delay_hr, "post_delay_hr")
  if (is.null(accrual_rate)) designr_stop("accrual_rate",
                                          "required for group-sequential NPH")
  check_pos(accrual_rate, "accrual_rate")
  check_pos(accrual_duration, "accrual_duration")
  if (is.null(analysis_times) || !is.numeric(analysis_times) ||
      length(analysis_times) < 2L || any(analysis_times <= 0) ||
      is.unsorted(analysis_times, strictly = TRUE)) {
    designr_stop("analysis_times",
                 "must be a strictly increasing numeric vector of length >= 2")
  }
  check_nonneg(dropout_rate, "dropout_rate")
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  if (sided != 1L) {
    designr_stop("sided", "NPH GS designs are one-sided only; use sided = 1")
  }
  check_ratio(allocation_ratio)
  sfu_name <- check_spending_fn(sfu, "sfu")
  if (!is.logical(binding) || length(binding) != 1L) {
    designr_stop("binding", "must be a single logical value")
  }
  if (!identical(comparison, "superiority")) {
    designr_stop("comparison",
                 "NPH GS designs only support superiority")
  }
  if (is.null(tau_fh)) tau_fh <- rep(-1, length(rho))

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

  out <- switch(model,
    "maxcombo" = {
      if (length(gamma) != length(rho) || length(tau_fh) != length(rho)) {
        designr_stop("rho", "rho, gamma, and tau_fh must all have the same length")
      }
      n_weights <- length(rho)
      fh_test <- do.call(rbind, lapply(seq_len(k), function(i) {
        data.frame(rho = rho, gamma = gamma, tau = tau_fh,
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
                                 rho = rho[1], gamma = gamma[1], tau = tau_fh[1])
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
    n_per_analysis      = as.numeric(analysis_df$n),
    accrual_duration    = accrual_duration,
    study_duration      = analysis_times[k],
    followup_duration   = analysis_times[k] - accrual_duration
  )

  .designr_result(
    sample_size_total   = n_total_max,
    sample_size_per_arm = c(control = n_control, treatment = n_treat),
    events_total        = events_max,
    boundaries          = boundaries,
    timing              = timing_out,
    inputs = list(
      model = model, design_class = "group-sequential",
      control_median = control_median,
      delay_months = delay_months, post_delay_hr = post_delay_hr,
      accrual_rate = accrual_rate,
      accrual_duration = accrual_duration,
      analysis_times = analysis_times,
      dropout_rate = dropout_rate,
      rho = rho, gamma = gamma, tau_fh = tau_fh,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      sfu = sfu, binding = binding,
      comparison = "superiority"
    ),
    method          = sprintf("gsDesign2::gs_design_%s", model),
    package_version = .pkg_version("gsDesign2"),
    raw             = list(ahr_schedule = as.data.frame(analysis_df))
  )
}
