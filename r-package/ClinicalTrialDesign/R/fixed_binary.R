#' Fixed-sample two-arm binary endpoint design
#'
#' Thin wrapper over [gsDesign::nBinomial()] covering superiority,
#' non-inferiority, and equivalence (the latter via a TOST-style power
#' calculation on the lower and upper equivalence margins).
#'
#' @param p_control,p_treatment Event probabilities in the control and
#'   treatment arms (both in (0, 1)).
#' @param alpha,power,sided Type-I error, desired power, and sidedness
#'   (1 or 2).
#' @param allocation_ratio Ratio n_treatment / n_control (default 1).
#' @param comparison One of "superiority", "non-inferiority", "equivalence".
#' @param ni_margin Required when `comparison == "non-inferiority"`. On the
#'   event-rate difference scale (e.g. 0.10). The NI hypothesis is
#'   p_treatment − p_control ≤ ni_margin (when higher is worse) or the
#'   mirror image; the sign is inferred from `p_treatment - p_control`.
#' @param equiv_margin Required when `comparison == "equivalence"`. Two-sided
#'   equivalence on the rate difference scale.
#'
#' @return A `designr` result list (see [utils_format]).
#' @export
design_fixed_binary <- function(p_control,
                                p_treatment,
                                alpha            = 0.05,
                                power            = 0.80,
                                sided            = 2,
                                allocation_ratio = 1,
                                comparison       = "superiority",
                                ni_margin        = NULL,
                                equiv_margin     = NULL) {
  check_prob(p_control, "p_control")
  check_prob(p_treatment, "p_treatment")
  if (isTRUE(all.equal(p_control, p_treatment)) && comparison == "superiority") {
    designr_stop("p_treatment", "must differ from p_control for a superiority test")
  }
  alpha <- check_alpha(alpha)
  power <- check_power(power)
  sided <- check_sided(sided)
  check_ratio(allocation_ratio)
  comparison <- check_comparison(comparison)

  beta <- 1 - power
  method <- NULL
  n_total <- NULL

  if (comparison == "superiority") {
    out <- gsDesign::nBinomial(
      p1     = p_control,
      p2     = p_treatment,
      alpha  = alpha,
      beta   = beta,
      sided  = sided,
      ratio  = allocation_ratio,
      outtype = 2
    )
    n_control <- as.numeric(out["n1"])
    n_treat   <- as.numeric(out["n2"])
    n_total   <- n_control + n_treat
    per_arm   <- c(control = n_control, treatment = n_treat)
    method    <- "gsDesign::nBinomial (superiority)"

  } else if (comparison == "non-inferiority") {
    if (is.null(ni_margin)) designr_stop("ni_margin",
                                         "required when comparison = 'non-inferiority'")
    check_pos(ni_margin, "ni_margin")
    delta0 <- ni_margin * sign(p_treatment - p_control)
    if (delta0 == 0) delta0 <- ni_margin
    out <- gsDesign::nBinomial(
      p1     = p_control,
      p2     = p_treatment,
      delta0 = delta0,
      alpha  = alpha,
      beta   = beta,
      sided  = 1,
      ratio  = allocation_ratio,
      outtype = 2
    )
    n_control <- as.numeric(out["n1"])
    n_treat   <- as.numeric(out["n2"])
    n_total   <- n_control + n_treat
    per_arm   <- c(control = n_control, treatment = n_treat)
    method    <- "gsDesign::nBinomial (non-inferiority)"

  } else {
    if (is.null(equiv_margin)) designr_stop("equiv_margin",
                                            "required when comparison = 'equivalence'")
    check_pos(equiv_margin, "equiv_margin")
    n_lo <- gsDesign::nBinomial(
      p1 = p_control, p2 = p_treatment,
      delta0 = -equiv_margin,
      alpha = alpha / 2, beta = beta, sided = 1,
      ratio = allocation_ratio, outtype = 2
    )
    n_hi <- gsDesign::nBinomial(
      p1 = p_control, p2 = p_treatment,
      delta0 = equiv_margin,
      alpha = alpha / 2, beta = beta, sided = 1,
      ratio = allocation_ratio, outtype = 2
    )
    n_control <- max(as.numeric(n_lo["n1"]), as.numeric(n_hi["n1"]))
    n_treat   <- max(as.numeric(n_lo["n2"]), as.numeric(n_hi["n2"]))
    n_total   <- n_control + n_treat
    per_arm   <- c(control = n_control, treatment = n_treat)
    method    <- "gsDesign::nBinomial (equivalence TOST)"
  }

  .designr_result(
    sample_size_total   = n_total,
    sample_size_per_arm = per_arm,
    inputs = list(
      p_control = p_control, p_treatment = p_treatment,
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison,
      ni_margin = ni_margin, equiv_margin = equiv_margin
    ),
    method          = method,
    package_version = .pkg_version("gsDesign")
  )
}
