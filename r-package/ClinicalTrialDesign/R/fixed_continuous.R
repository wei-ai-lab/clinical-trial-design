#' Fixed-sample two-arm continuous endpoint design
#'
#' Thin wrapper over [gsDesign::nNormal()] covering superiority,
#' non-inferiority, and equivalence.
#'
#' @param mean_diff Assumed mean difference (treatment − control). Must be
#'   non-zero for superiority.
#' @param sd Common (pooled) SD of the outcome on the per-subject scale.
#' @param alpha,power,sided,allocation_ratio,comparison As in [design_fixed_binary()].
#' @param ni_margin Absolute margin on the mean-difference scale (required
#'   when `comparison == "non-inferiority"`).
#' @param equiv_margin Absolute margin on the mean-difference scale
#'   (required when `comparison == "equivalence"`).
#'
#' @return A `designr` result list (see [utils_format]).
#' @export
design_fixed_continuous <- function(mean_diff,
                                    sd,
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
      alpha = alpha, power = power, sided = sided,
      allocation_ratio = allocation_ratio,
      comparison = comparison,
      ni_margin = ni_margin, equiv_margin = equiv_margin
    ),
    method          = method,
    package_version = .pkg_version("gsDesign")
  )
}
