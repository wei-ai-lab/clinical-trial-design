#' Monte Carlo verification of a designr result
#'
#' Takes a result produced by any `design_*` tool and runs a closed-form
#' Monte Carlo simulation under both H1 (target effect) and H0 (null
#' boundary) to estimate empirical power and Type I error. The computed
#' values are compared against a tolerance gate (default ±2 percentage
#' points for power, ±0.5 pp for Type I error) borrowed from
#' `RConsortium/pharma-skills`'s `lrsim()` convention.
#'
#' Supported families in v0.0.2:
#' - `design_fixed_binary` (superiority, non-inferiority)
#' - `design_fixed_continuous` (superiority, non-inferiority)
#' - `design_fixed_survival_ph` (superiority, non-inferiority)
#' - `design_gs_binary` (superiority, non-inferiority)
#' - `design_gs_continuous` (superiority, non-inferiority)
#' - `design_gs_survival_ph` (superiority, non-inferiority)
#'
#' Deferred to a future release: equivalence (TOST), NPH endpoints
#' (MaxCombo / RMST / milestone), GS NPH combo. Calling `verify_design`
#' on an unsupported result raises a `designr_input_error`.
#'
#' @param result A result list from a `design_*` tool (the same JSON shape
#'   the MCP bridge returns).
#' @param n_sim Number of simulation replicates per hypothesis (default
#'   5000). Larger is tighter; 5000 gives ~0.2 pp SE on a p=0.025 estimate.
#' @param seed Integer seed for reproducibility.
#' @param tolerance_power_pp Power tolerance in percentage points.
#' @param tolerance_type_I_pp Type I tolerance in percentage points.
#' @return A list with empirical_power, empirical_type_I, target_power,
#'   target_alpha, tolerance, passes (bool), and per-run details.
#' @export
verify_design <- function(result,
                          n_sim              = 5000,
                          seed               = 1,
                          tolerance_power_pp = 2,
                          tolerance_type_I_pp = 0.5) {
  if (!is.list(result) || is.null(result$method) || is.null(result$inputs)) {
    designr_stop("result", "must be a designr result list with $method and $inputs")
  }
  n_sim <- check_int(n_sim, "n_sim", lo = 100L, hi = 200000L)
  check_nonneg(seed, "seed")
  check_pos(tolerance_power_pp, "tolerance_power_pp")
  check_pos(tolerance_type_I_pp, "tolerance_type_I_pp")

  family <- .verify_detect_family(result$method)

  sim <- switch(family,
    fixed_binary      = .verify_fixed_binary(result, n_sim, seed),
    fixed_continuous  = .verify_fixed_continuous(result, n_sim, seed),
    fixed_survival_ph = .verify_fixed_survival_ph(result, n_sim, seed),
    gs_binary         = .verify_gs_binary(result, n_sim, seed),
    gs_continuous     = .verify_gs_continuous(result, n_sim, seed),
    gs_survival_ph    = .verify_gs_survival_ph(result, n_sim, seed)
  )

  target_power <- result$inputs$power
  target_alpha <- result$inputs$alpha
  power_diff_pp  <- abs(sim$empirical_power  - target_power) * 100
  type_I_diff_pp <- abs(sim$empirical_type_I - target_alpha) * 100
  passes <- (power_diff_pp  <= tolerance_power_pp) &&
            (type_I_diff_pp <= tolerance_type_I_pp)

  list(
    family           = family,
    n_sim            = n_sim,
    seed             = seed,
    target_power     = target_power,
    target_alpha     = target_alpha,
    empirical_power  = sim$empirical_power,
    empirical_type_I = sim$empirical_type_I,
    tolerance        = list(power_pp  = tolerance_power_pp,
                            type_I_pp = tolerance_type_I_pp),
    diffs_pp         = list(power_pp  = power_diff_pp,
                            type_I_pp = type_I_diff_pp),
    passes           = passes,
    details          = sim$details,
    method           = result$method
  )
}

.verify_detect_family <- function(method) {
  if (grepl("nBinomial", method, fixed = TRUE)) {
    if (grepl("equivalence", method, fixed = TRUE)) {
      designr_stop("result",
                   "equivalence (TOST) verification is deferred to a future release")
    }
    return("fixed_binary")
  }
  if (grepl("nNormal", method, fixed = TRUE)) {
    if (grepl("equivalence", method, fixed = TRUE)) {
      designr_stop("result",
                   "equivalence (TOST) verification is deferred to a future release")
    }
    return("fixed_continuous")
  }
  if (grepl("gsSurv", method, fixed = TRUE)) return("gs_survival_ph")
  if (grepl("nSurv",  method, fixed = TRUE)) return("fixed_survival_ph")
  if (grepl("gsDesign (binary",     method, fixed = TRUE)) return("gs_binary")
  if (grepl("gsDesign (continuous", method, fixed = TRUE)) return("gs_continuous")
  if (grepl("gs_design_combo", method, fixed = TRUE) ||
      grepl("gs_design_wlr",   method, fixed = TRUE) ||
      grepl("gs_design_ahr",   method, fixed = TRUE) ||
      grepl("fixed_design_maxcombo",  method, fixed = TRUE) ||
      grepl("fixed_design_rmst",      method, fixed = TRUE) ||
      grepl("fixed_design_milestone", method, fixed = TRUE)) {
    designr_stop("result",
                 sprintf("NPH verification (%s) is deferred; supported families: fixed binary, fixed continuous, fixed PH survival, GS binary, GS continuous, GS PH survival",
                         method))
  }
  designr_stop("result",
               sprintf("cannot infer family from method '%s'", method))
}

# Apply the rejection rule for a vector of (signed) Z statistics.
# `effect_sign` orients Z so that "treatment better in the favorable direction"
# is positive — for one-sided tests we reject only when (effect_sign * z) > z_crit.
.reject_z <- function(z, sided, z_crit, effect_sign, one_sided) {
  if (one_sided) {
    mean((effect_sign * z) > z_crit, na.rm = TRUE)
  } else {
    mean(abs(z) > z_crit, na.rm = TRUE)
  }
}

# ----- Fixed binary ---------------------------------------------------------

.verify_fixed_binary <- function(result, n_sim, seed) {
  inp <- result$inputs
  n_c <- result$sample_size_per_arm[["control"]]
  n_t <- result$sample_size_per_arm[["treatment"]]
  p_c <- inp$p_control
  p_t <- inp$p_treatment
  alpha <- inp$alpha
  sided <- inp$sided
  z_crit <- if (inp$comparison == "non-inferiority" || sided == 1) {
    stats::qnorm(1 - alpha)
  } else {
    stats::qnorm(1 - alpha / 2)
  }
  # Under NI, delta0 is the margin with the worse-direction sign. Under
  # superiority, delta0 = 0.
  delta0 <- if (inp$comparison == "non-inferiority") {
    inp$ni_margin * sign(p_t - p_c)
  } else 0

  effect_sign <- sign(p_t - p_c)
  if (effect_sign == 0) effect_sign <- 1
  reject_binary <- function(pC, pT) {
    set.seed(seed)
    xC <- stats::rbinom(n_sim, n_c, pC)
    xT <- stats::rbinom(n_sim, n_t, pT)
    phatC <- xC / n_c; phatT <- xT / n_t
    diff <- phatT - phatC - delta0
    pooled <- (xC + xT) / (n_c + n_t)
    se <- sqrt(pooled * (1 - pooled) * (1 / n_c + 1 / n_t))
    se[se == 0] <- NA_real_
    z <- diff / se
    .reject_z(z, sided = sided, z_crit = z_crit, effect_sign = effect_sign,
              one_sided = inp$comparison == "non-inferiority" || sided == 1)
  }

  power_emp <- reject_binary(p_c, p_t)
  # H0 for superiority: p_t = p_c. H0 for NI: p_t at the boundary.
  p_t_H0 <- if (inp$comparison == "non-inferiority") p_c + delta0 else p_c
  type_I_emp <- reject_binary(p_c, p_t_H0)

  list(empirical_power  = power_emp,
       empirical_type_I = type_I_emp,
       details          = list(n_control = n_c, n_treatment = n_t,
                               delta0 = delta0, z_crit = z_crit))
}

# ----- Fixed continuous -----------------------------------------------------

.verify_fixed_continuous <- function(result, n_sim, seed) {
  inp <- result$inputs
  n_c <- result$sample_size_per_arm[["control"]]
  n_t <- result$sample_size_per_arm[["treatment"]]
  sd <- inp$sd
  mean_diff <- inp$mean_diff
  alpha <- inp$alpha
  sided <- inp$sided
  z_crit <- if (inp$comparison == "non-inferiority" || sided == 1) {
    stats::qnorm(1 - alpha)
  } else {
    stats::qnorm(1 - alpha / 2)
  }
  delta0 <- if (inp$comparison == "non-inferiority") {
    inp$ni_margin * sign(mean_diff)
  } else 0

  effect_sign <- sign(mean_diff); if (effect_sign == 0) effect_sign <- 1
  reject_cont <- function(mu_c, mu_t) {
    set.seed(seed)
    Xc <- matrix(stats::rnorm(n_sim * n_c, mu_c, sd), ncol = n_c)
    Xt <- matrix(stats::rnorm(n_sim * n_t, mu_t, sd), ncol = n_t)
    mc <- rowMeans(Xc); mt <- rowMeans(Xt)
    # Pooled-variance z-test (matches gsDesign::nNormal's sd2 = sd assumption).
    se <- sd * sqrt(1 / n_c + 1 / n_t)
    z <- (mt - mc - delta0) / se
    .reject_z(z, sided = sided, z_crit = z_crit, effect_sign = effect_sign,
              one_sided = inp$comparison == "non-inferiority" || sided == 1)
  }

  power_emp <- reject_cont(0, mean_diff)
  mu_t_H0 <- if (inp$comparison == "non-inferiority") delta0 else 0
  type_I_emp <- reject_cont(0, mu_t_H0)

  list(empirical_power  = power_emp,
       empirical_type_I = type_I_emp,
       details          = list(n_control = n_c, n_treatment = n_t,
                               delta0 = delta0, z_crit = z_crit))
}

# ----- Fixed PH survival ----------------------------------------------------

.verify_fixed_survival_ph <- function(result, n_sim, seed) {
  inp <- result$inputs
  n_c <- result$sample_size_per_arm[["control"]]
  n_t <- result$sample_size_per_arm[["treatment"]]
  lambdaC <- log(2) / inp$control_median
  hr  <- inp$hazard_ratio
  hr0 <- inp$hr_null
  if (is.null(hr0) || is.na(hr0)) hr0 <- 1
  R <- inp$accrual_duration
  mf <- inp$followup_duration
  T <- R + mf
  alpha <- inp$alpha
  sided <- inp$sided
  z_crit <- if (inp$comparison == "non-inferiority" || sided == 1) {
    stats::qnorm(1 - alpha)
  } else {
    stats::qnorm(1 - alpha / 2)
  }

  # Score-based log-rank Z under exponential PH, with the null shifted by
  # log(hr0). This is the standard fixed-sample analytic form and matches
  # gsDesign::nSurv's theta structure exactly, so the simulation cross-
  # checks the formula with the same asymptotic test the formula targets.
  sim_once <- function(hr_sim) {
    set.seed(seed + round(1e6 * hr_sim))
    lambdaT <- lambdaC * hr_sim
    enroll_c <- stats::runif(n_c * n_sim, 0, R)
    enroll_t <- stats::runif(n_t * n_sim, 0, R)
    time_c   <- stats::rexp(n_c * n_sim, lambdaC)
    time_t   <- stats::rexp(n_t * n_sim, lambdaT)
    # Column = replicate; row = subject. Reshape.
    ec <- matrix(enroll_c, ncol = n_sim)
    et <- matrix(enroll_t, ncol = n_sim)
    tc <- matrix(time_c,   ncol = n_sim)
    tt <- matrix(time_t,   ncol = n_sim)
    # Admin censoring at T - enroll_i.
    obs_c <- pmin(tc, T - ec); evt_c <- tc <= (T - ec)
    obs_t <- pmin(tt, T - et); evt_t <- tt <= (T - et)

    # For each replicate, compute log-rank Z with optional hr0 shift. We
    # use a simple score: sum over event times of (O_T - E_T) where E_T
    # is the expected count under H0.
    z_vec <- vapply(seq_len(n_sim), function(j) {
      t_all <- c(obs_c[, j], obs_t[, j])
      e_all <- c(evt_c[, j], evt_t[, j])
      grp   <- c(rep(0, n_c), rep(1, n_t))
      ord <- order(t_all)
      t_all <- t_all[ord]; e_all <- e_all[ord]; grp <- grp[ord]
      # At each event time, compute risk sets.
      keep <- which(e_all == 1)
      if (length(keep) == 0) return(NA_real_)
      O1 <- E1 <- V <- 0
      nrisk_c <- n_c; nrisk_t <- n_t
      i <- 1L
      while (i <= length(t_all)) {
        # Advance the risk sets by censored observations before next event.
        # Simpler: at each subject, update the risk set after it leaves.
        if (e_all[i] == 1) {
          nr <- nrisk_c + nrisk_t
          if (nr > 1 && nrisk_c > 0 && nrisk_t > 0) {
            E1 <- E1 + nrisk_t / nr
            V  <- V + (nrisk_c * nrisk_t) / (nr * nr)
            O1 <- O1 + grp[i]
          }
        }
        if (grp[i] == 0) nrisk_c <- nrisk_c - 1
        else             nrisk_t <- nrisk_t - 1
        i <- i + 1L
      }
      # The log-HR under H0=hr0 shifts the expected events by log(hr0).
      # Score form: U = O1 - E1; the expected count under HR=hr0 is
      # E1_prime = sum_{events} (nrisk_t * hr0) / (nrisk_c + nrisk_t * hr0).
      # For simplicity and since typically hr0=1 (superiority), we apply
      # the shift via a fixed-offset normal approximation: Z = (O1 - E1)
      # / sqrt(V) - log(hr0) * sqrt(V). This equals the standard form
      # when hr0 = 1.
      if (V <= 0) return(NA_real_)
      z <- (O1 - E1) / sqrt(V) - log(hr0) * sqrt(V)
      # Sign convention: negative z = treatment better (fewer events in T).
      -z
    }, numeric(1))

    # For survival, "treatment better" = HR < 1, which by my sign convention
    # gives positive z. effect_sign = +1 when HR < 1.
    eff <- sign(1 - hr); if (eff == 0) eff <- 1
    .reject_z(z_vec, sided = sided, z_crit = z_crit, effect_sign = eff,
              one_sided = inp$comparison == "non-inferiority" || sided == 1)
  }

  power_emp <- sim_once(hr)
  # H0 for superiority: HR = 1. For NI: HR = hr0 (the margin).
  hr_H0 <- if (inp$comparison == "non-inferiority") hr0 else 1
  type_I_emp <- sim_once(hr_H0)

  list(empirical_power  = power_emp,
       empirical_type_I = type_I_emp,
       details          = list(n_control = n_c, n_treatment = n_t,
                               hr = hr, hr_null = hr0, z_crit = z_crit))
}

# ----- GS binary / continuous ----------------------------------------------

.verify_gs_binary <- function(result, n_sim, seed) {
  .verify_gs_two_sample(result, n_sim, seed, family = "binary")
}
.verify_gs_continuous <- function(result, n_sim, seed) {
  .verify_gs_two_sample(result, n_sim, seed, family = "continuous")
}

.verify_gs_two_sample <- function(result, n_sim, seed, family) {
  inp <- result$inputs
  bounds <- result$boundaries$upper_z
  n_per_analysis_total <- result$timing$n_per_analysis
  ratio <- inp$allocation_ratio %||% 1
  n_c_by <- n_per_analysis_total / (1 + ratio)
  n_t_by <- n_per_analysis_total - n_c_by
  # Round per-analysis N to integer sample sizes.
  n_c_by <- round(n_c_by); n_t_by <- round(n_t_by)
  K <- length(bounds)

  if (family == "binary") {
    p_c <- inp$p_control; p_t <- inp$p_treatment
    delta0 <- if (inp$comparison == "non-inferiority") {
      inp$ni_margin * sign(p_t - p_c)
    } else 0
    eff <- sign(p_t - p_c); if (eff == 0) eff <- 1
    sim_reject_bin <- function(pC, pT) {
      set.seed(seed + round(1e6 * pT))
      n_c_max <- n_c_by[K]; n_t_max <- n_t_by[K]
      Xc <- matrix(stats::rbinom(n_sim * n_c_max, 1, pC), ncol = n_c_max)
      Xt <- matrix(stats::rbinom(n_sim * n_t_max, 1, pT), ncol = n_t_max)
      rejected <- rep(FALSE, n_sim)
      for (k in seq_len(K)) {
        nk_c <- n_c_by[k]; nk_t <- n_t_by[k]
        sumC <- rowSums(Xc[, seq_len(nk_c), drop = FALSE])
        sumT <- rowSums(Xt[, seq_len(nk_t), drop = FALSE])
        phatC <- sumC / nk_c; phatT <- sumT / nk_t
        pooled <- (sumC + sumT) / (nk_c + nk_t)
        se <- sqrt(pooled * (1 - pooled) * (1 / nk_c + 1 / nk_t))
        se[se == 0] <- NA_real_
        z <- (phatT - phatC - delta0) / se
        # gsDesign boundaries are upper one-sided in the favorable direction.
        crossed <- (eff * z) > bounds[k]
        rejected <- rejected | (crossed & !is.na(crossed))
      }
      mean(rejected)
    }
    power_emp <- sim_reject_bin(p_c, p_t)
    p_t_H0 <- if (inp$comparison == "non-inferiority") p_c + delta0 else p_c
    type_I_emp <- sim_reject_bin(p_c, p_t_H0)
    list(empirical_power = power_emp, empirical_type_I = type_I_emp,
         details = list(bounds = bounds, n_per_analysis = n_per_analysis_total,
                        delta0 = delta0))

  } else {  # continuous
    sd <- inp$sd; mean_diff <- inp$mean_diff
    delta0 <- if (inp$comparison == "non-inferiority") {
      inp$ni_margin * sign(mean_diff)
    } else 0
    eff <- sign(mean_diff); if (eff == 0) eff <- 1
    sim_reject_cont <- function(mu_c, mu_t) {
      set.seed(seed + round(1e6 * mu_t))
      n_c_max <- n_c_by[K]; n_t_max <- n_t_by[K]
      Xc <- matrix(stats::rnorm(n_sim * n_c_max, mu_c, sd), ncol = n_c_max)
      Xt <- matrix(stats::rnorm(n_sim * n_t_max, mu_t, sd), ncol = n_t_max)
      rejected <- rep(FALSE, n_sim)
      for (k in seq_len(K)) {
        nk_c <- n_c_by[k]; nk_t <- n_t_by[k]
        mk_c <- rowMeans(Xc[, seq_len(nk_c), drop = FALSE])
        mk_t <- rowMeans(Xt[, seq_len(nk_t), drop = FALSE])
        se <- sd * sqrt(1 / nk_c + 1 / nk_t)
        z <- (mk_t - mk_c - delta0) / se
        crossed <- (eff * z) > bounds[k]
        rejected <- rejected | crossed
      }
      mean(rejected)
    }
    power_emp <- sim_reject_cont(0, mean_diff)
    mu_t_H0 <- if (inp$comparison == "non-inferiority") delta0 else 0
    type_I_emp <- sim_reject_cont(0, mu_t_H0)
    list(empirical_power = power_emp, empirical_type_I = type_I_emp,
         details = list(bounds = bounds, n_per_analysis = n_per_analysis_total,
                        delta0 = delta0))
  }
}

# ----- GS PH survival -------------------------------------------------------

.verify_gs_survival_ph <- function(result, n_sim, seed) {
  inp <- result$inputs
  bounds <- result$boundaries$upper_z
  analysis_times <- result$timing$analysis_times
  K <- length(bounds)
  n_c <- result$sample_size_per_arm[["control"]]
  n_t <- result$sample_size_per_arm[["treatment"]]
  lambdaC <- log(2) / inp$control_median
  hr  <- inp$hazard_ratio
  hr0 <- inp$hr_null; if (is.null(hr0)) hr0 <- 1
  R <- inp$accrual_duration

  sim_once <- function(hr_sim) {
    set.seed(seed + round(1e6 * hr_sim))
    lambdaT <- lambdaC * hr_sim
    rejected <- rep(FALSE, n_sim)
    for (j in seq_len(n_sim)) {
      ec <- stats::runif(n_c, 0, R); et <- stats::runif(n_t, 0, R)
      tc <- stats::rexp(n_c, lambdaC); tt <- stats::rexp(n_t, lambdaT)
      cal_c <- ec + tc; cal_t <- et + tt
      enroll_all <- c(ec, et)
      cal_all    <- c(cal_c, cal_t)
      grp        <- c(rep(0L, n_c), rep(1L, n_t))
      # For each calendar-time analysis, censor at that time and compute
      # the cumulative log-rank Z. Walk analyses left-to-right.
      for (k in seq_len(K)) {
        ta <- analysis_times[k]
        # Subjects with enrollment > ta are not yet enrolled — exclude.
        # For enrolled subjects, censor at ta if event later.
        in_trial <- enroll_all <= ta
        obs <- pmin(cal_all[in_trial], ta)
        evt <- cal_all[in_trial] <= ta
        gk  <- grp[in_trial]
        # Compute log-rank Z over the at-risk set (subjects in_trial,
        # observation times = obs, event indicators = evt).
        z <- .lr_z(obs, evt, gk, hr0)
        if (!is.na(z) && z > bounds[k]) {
          rejected[j] <- TRUE
          break
        }
      }
    }
    mean(rejected)
  }

  power_emp <- sim_once(hr)
  hr_H0 <- if (inp$comparison == "non-inferiority") hr0 else 1
  type_I_emp <- sim_once(hr_H0)

  list(empirical_power  = power_emp,
       empirical_type_I = type_I_emp,
       details          = list(n_control = n_c, n_treatment = n_t,
                               analysis_times = analysis_times,
                               bounds = bounds,
                               hr = hr, hr_null = hr0))
}

# Score-based log-rank Z for two arms, optionally shifted by log(hr0). Returns
# Z oriented so that "treatment better" (HR < hr0) gives positive Z.
.lr_z <- function(obs, evt, grp, hr0 = 1) {
  if (length(obs) < 2) return(NA_real_)
  ord <- order(obs)
  obs <- obs[ord]; evt <- evt[ord]; grp <- grp[ord]
  O1 <- E1 <- V <- 0
  nrisk_c <- sum(grp == 0L); nrisk_t <- sum(grp == 1L)
  for (i in seq_along(obs)) {
    if (evt[i] == 1L) {
      nr <- nrisk_c + nrisk_t
      if (nr > 1 && nrisk_c > 0 && nrisk_t > 0) {
        E1 <- E1 + nrisk_t / nr
        V  <- V + (nrisk_c * nrisk_t) / (nr * nr)
        O1 <- O1 + grp[i]
      }
    }
    if (grp[i] == 0L) nrisk_c <- nrisk_c - 1L
    else              nrisk_t <- nrisk_t - 1L
  }
  if (V <= 0) return(NA_real_)
  -((O1 - E1) / sqrt(V) - log(hr0) * sqrt(V))
}
